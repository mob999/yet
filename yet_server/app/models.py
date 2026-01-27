from datetime import UTC, datetime

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from .database import Base


class TimestampMixin:
    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime, default=lambda: datetime.now(UTC), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(UTC), onupdate=lambda: datetime.now(UTC), nullable=False)
    deleted_at = Column(DateTime, nullable=True)


class User(TimestampMixin, Base):
    __tablename__ = "users"

    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)

    profile = relationship("UserProfile", back_populates="user", uselist=False)
    groups = relationship("GroupMember", back_populates="user")
    created_groups = relationship("Group", back_populates="creator")


class UserProfile(TimestampMixin, Base):
    __tablename__ = "user_profiles"

    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    avatar_url = Column(String, nullable=True)
    gender = Column(String, nullable=True)
    birth_date = Column(DateTime, nullable=True)

    user = relationship("User", back_populates="profile")


class SystemLog(TimestampMixin, Base):
    __tablename__ = "system_logs"

    level = Column(String, index=True)
    message = Column(String)
    module = Column(String, nullable=True)
    function = Column(String, nullable=True)
    line = Column(Integer, nullable=True)


class Group(TimestampMixin, Base):
    __tablename__ = "groups"

    name = Column(String, nullable=False)
    invite_code = Column(String, unique=True, index=True, nullable=False)
    creator_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    creator = relationship("User", back_populates="created_groups")
    members = relationship("GroupMember", back_populates="group", cascade="all, delete-orphan")


class GroupMember(TimestampMixin, Base):
    __tablename__ = "group_members"

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    group_id = Column(Integer, ForeignKey("groups.id"), nullable=False)
    # joined_at is essentially created_at, but we can keep semantic alias or just use created_at
    # Let's use created_at from Mixin to represent join time
    
    user = relationship("User", back_populates="groups")
    group = relationship("Group", back_populates="members")
