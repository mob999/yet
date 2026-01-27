import sys
from loguru import logger
from sqlalchemy.orm import Session
from .database import SessionLocal
from .models import SystemLog

class DatabaseSink:
    def __init__(self):
        pass

    def write(self, message):
        record = message.record
        # Only log WARNING, ERROR, CRITICAL to DB by default, or you can change as needed
        # User requested "important information", so Level >= INFO might be okay, 
        # but let's stick to INFO and above for persistence to avoid bloating.
        
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
            # Fallback to stderr if DB logging fails to avoid losing the log
            sys.stderr.write(f"Failed to log to database: {e}\n")
        finally:
            db.close()

def setup_logging():
    # Remove default handler
    logger.remove()

    # Add console handler
    logger.add(
        sys.stdout, 
        format="<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
        level="INFO"
    )

    # Add database sink (only for INFO and above)
    logger.add(
        DatabaseSink().write,
        level="INFO"
    )

setup_logging()
