from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from app.models.db import Base
from datetime import datetime

class TokenBlacklist(Base):
    __tablename__ = "token_blacklist"

    token: Mapped[str] = mapped_column(String, primary_key=True, index=True)
    blacklisted_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)