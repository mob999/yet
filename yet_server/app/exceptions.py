from fastapi import Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from typing import Any, Optional
from loguru import logger

class APIException(Exception):
    """Base API Exception"""
    def __init__(
        self, 
        message: str, 
        code: int = 400, 
        status_code: int = status.HTTP_400_BAD_REQUEST,
        data: Optional[Any] = None
    ):
        self.message = message
        self.code = code
        self.status_code = status_code
        self.data = data

class AuthenticationError(APIException):
    def __init__(self, message: str = "Authentication failed"):
        super().__init__(message, code=401, status_code=status.HTTP_401_UNAUTHORIZED)

class PermissionError(APIException):
    def __init__(self, message: str = "Permission denied"):
        super().__init__(message, code=403, status_code=status.HTTP_403_FORBIDDEN)

class NotFoundError(APIException):
    def __init__(self, message: str = "Resource not found"):
        super().__init__(message, code=404, status_code=status.HTTP_404_NOT_FOUND)

class BusinessError(APIException):
    def __init__(self, message: str, code: int = 400):
        super().__init__(message, code=code, status_code=status.HTTP_400_BAD_REQUEST)

async def api_exception_handler(request: Request, exc: APIException):
    logger.warning(f"API Exception: {exc.message} (code={exc.code}, status={exc.status_code})")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "code": exc.code,
            "message": exc.message,
            "data": exc.data
        },
    )

async def validation_exception_handler(request: Request, exc: RequestValidationError):
    logger.warning(f"Validation Error: {exc.errors()}")
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "code": 422,
            "message": "Validation Error",
            "data": exc.errors()
        },
    )

async def global_exception_handler(request: Request, exc: Exception):
    logger.exception(f"Unhandled Exception: {exc}")
    # Log the full exception here in a real app
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "code": 500,
            "message": "Internal Server Error",
            "data": str(exc) if True else None # Set to False in production
        },
    )
