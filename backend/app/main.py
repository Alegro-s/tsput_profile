from datetime import datetime, time, timedelta, UTC
from fastapi import Body, FastAPI, Header, HTTPException

from .config import settings
from .schemas import (
    ExamItem,
    GradeItem,
    LabItem,
    LoginRequest,
    LoginResponse,
    PartnerScanBody,
    PartnerServiceItem,
    PortfolioItem,
    ScheduleItem,
    StudentResponse,
)

app = FastAPI(title=settings.app_name)


def _require_auth(authorization: str | None) -> None:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Unauthorized")


def _bearer_token(authorization: str | None) -> str:
    _require_auth(authorization)
    assert authorization is not None
    return authorization.split(" ", 1)[1].strip()


# Персональные услуги по QR (в проде — запись в БД / 1С по токену студента).
_partner_services_by_token: dict[str, list[PartnerServiceItem]] = {}


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
        },
    )


def _week_slot(weekday: int, hour: int, minute: int, **kwargs) -> ScheduleItem:
    """weekday 0=пн … 6=вс от текущей календарной недели (UTC)."""
    today = datetime.now(UTC).date()
    monday = today - timedelta(days=today.weekday())
    day = monday + timedelta(days=weekday)
    start = datetime.combine(day, time(hour, minute), tzinfo=UTC)
    return ScheduleItem(
        startTime=start,
        endTime=start + timedelta(hours=1, minutes=35),
        **kwargs,
    )


@app.get("/api/schedule", response_model=list[ScheduleItem])
def schedule(authorization: str | None = Header(default=None)) -> list[ScheduleItem]:
    _require_auth(authorization)
    return [
        _week_slot(
            0,
            8,
            40,
            id="S1",
            subject="Большие данные и распределенные системы",
            teacher="Добровольский Николай Николаевич",
            classroom="3-309-3",
            type="лекция",
        ),
        _week_slot(
            0,
            10,
            25,
            id="S2",
            subject="Большие данные и распределенные системы",
            teacher="Добровольский Николай Николаевич",
            classroom="3-308а-3",
            type="лабораторная",
        ),
        _week_slot(
            1,
            8,
            40,
            id="S3",
            subject="Экономико-математические методы и модели",
            teacher="Рарова Елена Михайловна",
            classroom="3-313-3",
            type="лекция",
        ),
        _week_slot(
            3,
            8,
            40,
            id="S4",
            subject="Методы оптимизации",
            teacher="Родионов Александр Валерьевич",
            classroom="3-313-3",
            type="лекция",
        ),
    ]


@app.get("/api/grades", response_model=list[GradeItem])
def grades(authorization: str | None = Header(default=None)) -> list[GradeItem]:
    _require_auth(authorization)
    # Демо-данные в духе ведомости из 1С (семестр, ЗЕТ, часы, подпись оценки).
    return [
        GradeItem(
            id="G1",
            subject="Безопасность жизнедеятельности",
            teacher="—",
            value=0,
            type="Зачёт",
            date=datetime(2022, 12, 23, tzinfo=UTC),
            semester=1,
            zet=3,
            hours=108,
            gradeLabel="Зачтено",
        ),
        GradeItem(
            id="G2",
            subject="Введение в программирование",
            teacher="—",
            value=4,
            type="Экзамен",
            date=datetime(2023, 1, 17, tzinfo=UTC),
            semester=1,
            zet=5,
            hours=180,
            gradeLabel="Хорошо",
        ),
        GradeItem(
            id="G3",
            subject="Дискретная математика",
            teacher="—",
            value=0,
            type="Зачёт",
            date=datetime(2022, 12, 28, tzinfo=UTC),
            semester=1,
            zet=4,
            hours=144,
            gradeLabel="Зачтено",
        ),
        GradeItem(
            id="G4",
            subject="Математический анализ",
            teacher="—",
            value=4,
            type="Экзамен",
            date=datetime(2023, 1, 12, tzinfo=UTC),
            semester=1,
            zet=5,
            hours=180,
            gradeLabel="Хорошо",
        ),
        GradeItem(
            id="G5",
            subject="Алгоритмы",
            teacher="Петров А.А.",
            value=5,
            type="лабораторная",
            date=datetime.now(UTC) - timedelta(days=5),
            semester=7,
            zet=3,
            hours=36,
        ),
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


@app.post("/api/partner-services/scan")
def partner_scan(
    authorization: str | None = Header(default=None),
    body: PartnerScanBody = Body(...),
) -> dict:
    tok = _bearer_token(authorization)
    raw = body.raw.strip()
    if not raw:
        raise HTTPException(status_code=400, detail="empty raw")
    item = PartnerServiceItem(
        id=f"ps_{abs(hash(raw)) % 10 ** 10}",
        title="Услуга по QR",
        partnerName="Партнёр (интеграция)",
        description=raw if len(raw) <= 500 else raw[:497] + "...",
        validUntil=None,
    )
    _partner_services_by_token.setdefault(tok, []).append(item)
    return {"ok": True}


@app.get("/api/partner-services", response_model=list[PartnerServiceItem])
def partner_services_list(authorization: str | None = Header(default=None)) -> list[PartnerServiceItem]:
    tok = _bearer_token(authorization)
    return list(_partner_services_by_token.get(tok, []))


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
