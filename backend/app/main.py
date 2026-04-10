from datetime import datetime, timedelta, UTC
from fastapi import FastAPI, Header, HTTPException

from .config import settings
from .schemas import (
    ExamItem,
    GradeItem,
    LabItem,
    LoginRequest,
    LoginResponse,
    PortfolioItem,
    ScheduleItem,
    StudentResponse,
)

app = FastAPI(title=settings.app_name)


def _require_auth(authorization: str | None) -> None:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Unauthorized")


@app.get("/health")
def health() -> dict:
    return {"ok": True, "env": settings.app_env, "mock_mode": settings.mock_mode}


@app.post("/api/sync")
def sync() -> dict:
    return {"success": True}


@app.post("/api/auth/login", response_model=LoginResponse)
def login(payload: LoginRequest) -> LoginResponse:
    if payload.login == settings.api_demo_login and payload.password == settings.api_demo_password:
        return LoginResponse(
            success=True,
            token=f"demo_{int(datetime.now(UTC).timestamp())}",
            user={
                "id": "ST001",
                "name": "Виноградов Игорь Денисович",
                "group": "1521621",
            },
        )
    return LoginResponse(success=False, error="Неверный логин или пароль")


@app.get("/api/student", response_model=StudentResponse)
def student(authorization: str | None = Header(default=None)) -> StudentResponse:
    _require_auth(authorization)
    return StudentResponse(
        id="ST001",
        fullName="Виноградов Игорь Денисович",
        group="1521621",
        faculty="Институт передовых информационных технологий",
        specialty="Математическое обеспечение и администрирование информационных систем",
        course=4,
        admissionDate=datetime(2022, 9, 1, tzinfo=UTC),
        graduationDate=datetime(2026, 6, 30, tzinfo=UTC),
        email="lorm2053@gmail.com",
        phone="+7 (900) 000-00-00",
        address="г. Тула",
        additionalInfo={
            "recordBook": "22031-15",
            "educationForm": "Очная",
            "city": "Tula",
            "timezone": "Etc/GMT-3",
            "birthDate": "2004-10-21",
            "studentStatus": "Является студентом",
            "trainingLevel": "Бакалавриат",
            "profile": "Информационные системы и базы данных",
            "scholarship": 0,
            "dormitory": "Не указано",
            "averageGrade": 4.7,
            "examsCount": 8,
            "partnerMapAccess": False,
        },
    )


@app.get("/api/schedule", response_model=list[ScheduleItem])
def schedule(authorization: str | None = Header(default=None)) -> list[ScheduleItem]:
    _require_auth(authorization)
    now = datetime.now(UTC)
    return [
        ScheduleItem(
            id="S1",
            subject="Базы данных",
            teacher="Сидоров И.И.",
            classroom="312",
            startTime=now + timedelta(hours=2),
            endTime=now + timedelta(hours=3, minutes=30),
            type="лекция",
        )
    ]


@app.get("/api/grades", response_model=list[GradeItem])
def grades(authorization: str | None = Header(default=None)) -> list[GradeItem]:
    _require_auth(authorization)
    return [
        GradeItem(
            id="G1",
            subject="Алгоритмы",
            teacher="Петров А.А.",
            value=5,
            type="лабораторная",
            date=datetime.now(UTC) - timedelta(days=5),
        )
    ]


@app.get("/api/exams", response_model=list[ExamItem])
def exams(authorization: str | None = Header(default=None)) -> list[ExamItem]:
    _require_auth(authorization)
    return [
        ExamItem(
            id="E1",
            subject="Компьютерные сети",
            teacher="Иванова Н.В.",
            date="20.04.2026",
            time="10:00",
            classroom="ауд. 102",
            isCompleted=False,
            type="экзамен",
        )
    ]


@app.get("/api/portfolio", response_model=list[PortfolioItem])
def portfolio(authorization: str | None = Header(default=None)) -> list[PortfolioItem]:
    _require_auth(authorization)
    return [
        PortfolioItem(
            id="P1",
            title="Методы оптимизации 2025 - 2026",
            category="Учебная дисциплина",
            status="Подтверждено",
            date=datetime.now(UTC) - timedelta(days=120),
            source="1C/Учебный план",
        ),
        PortfolioItem(
            id="P2",
            title="Большие данные и распределенные системы 2025 - 2026",
            category="Учебная дисциплина",
            status="Подтверждено",
            date=datetime.now(UTC) - timedelta(days=110),
            source="1C/Учебный план",
        ),
        PortfolioItem(
            id="P3",
            title="Производственная преддипломная практика 2025 - 2026",
            category="Практика",
            status="В процессе",
            date=datetime.now(UTC) - timedelta(days=90),
            source="1C/Практика",
        ),
        PortfolioItem(
            id="P4",
            title="Экономико-математические методы и модели 2025 - 2026",
            category="Учебная дисциплина",
            status="Подтверждено",
            date=datetime.now(UTC) - timedelta(days=80),
            source="1C/Учебный план",
        ),
        PortfolioItem(
            id="P5",
            title="Подготовка к процедуре защиты ВКР 2025 - 2026",
            category="ВКР",
            status="В процессе",
            date=datetime.now(UTC) - timedelta(days=60),
            source="1C/ВКР",
        ),
        PortfolioItem(
            id="P6",
            title="Компьютерное моделирование 2025 - 2026",
            category="Учебная дисциплина",
            status="Подтверждено",
            date=datetime.now(UTC) - timedelta(days=50),
            source="1C/Учебный план",
        ),
        PortfolioItem(
            id="P7",
            title="Рекурсивно-логическое программирование 2025 - 2026",
            category="Учебная дисциплина",
            status="Подтверждено",
            date=datetime.now(UTC) - timedelta(days=40),
            source="1C/Учебный план",
        ),
    ]


@app.get("/api/moodle/labs", response_model=list[LabItem])
def moodle_labs(authorization: str | None = Header(default=None)) -> list[LabItem]:
    _require_auth(authorization)
    return [
        LabItem(
            id="L1",
            course="Программирование",
            title="ЛР №3",
            status="Принято",
            teacherComment="Хорошая реализация, добавьте тесты.",
            updatedAt=datetime.now(UTC) - timedelta(hours=6),
        )
    ]
