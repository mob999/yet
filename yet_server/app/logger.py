import sys

from loguru import logger
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from .config import settings
from .models import SystemLog

# We use a separate sync engine for the logger to avoid async complexity 
# in the logging sink, which is synchronous by design in loguru.
sync_engine = create_engine(
    settings.DATABASE_URL.replace("sqlite+aiosqlite", "sqlite"),
    connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=sync_engine)

class DatabaseSink:
    def write(self, message):
        record = message.record
        db = SessionLocal()
        try:
            log_entry = SystemLog(
                level=record["level"].name,
                message=record["message"],
                module=record["module"],
                function=record["function"],
                line=record["line"]
            )
            db.add(log_entry)
            db.commit()
        except Exception as e:
            sys.stderr.write(f"Failed to log to database: {e}\n")
        finally:
            db.close()

def setup_logging():
    logger.remove()

    # Console handler
    logger.add(
        sys.stdout, 
        format="<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
        level="INFO"
    )

    # Database sink
    logger.add(
        DatabaseSink().write,
        level="INFO"
    )

setup_logging()
