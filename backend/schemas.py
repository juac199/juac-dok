from datetime import date

from pydantic import BaseModel


# ============================================================
# STUDENTS
# ============================================================

class StudentCreate(BaseModel):
    full_name: str
    email: str
    password: str
    student_number: str
    date_of_birth: date | None = None
    phone: str = ""
    address: str | None = None
    program: str = ""
    enrollment_date: date | None = None


class StudentUpdate(BaseModel):
    full_name: str
    email: str
    student_number: str
    date_of_birth: date | None = None
    phone: str = ""
    address: str | None = None
    program: str = ""
    enrollment_date: date | None = None


# ============================================================
# LECTURERS
# ============================================================

class LecturerCreate(BaseModel):
    full_name: str
    email: str
    password: str
    lecturer_number: str
    department: str
    phone: str
    specialization: str | None = None
    hire_date: date


class LecturerUpdate(BaseModel):
    full_name: str
    email: str
    lecturer_number: str
    department: str
    phone: str
    specialization: str | None = None
    hire_date: date


# ============================================================
# AUTHENTICATION
# ============================================================

class LoginRequest(BaseModel):
    email: str
    password: str


# ============================================================
# SUBJECTS
# ============================================================

class SubjectCreate(BaseModel):
    subject_code: str
    subject_name: str
    credit_hours: int
    description: str | None = None


class SubjectUpdate(BaseModel):
    subject_code: str
    subject_name: str
    credit_hours: int
    description: str | None = None


# ============================================================
# SUBJECT REGISTRATION
# ============================================================

class SubjectRegistrationCreate(BaseModel):
    subject_id: int
    semester: str
    academic_year: str


# ============================================================
# RESULTS
# ============================================================

class ResultCreate(BaseModel):
    student_id: int
    subject_id: int
    semester: str
    academic_year: str
    marks: float


class ResultUpdate(BaseModel):
    marks: float
    status: str


class ResultPublish(BaseModel):
    status: str


# ============================================================
# ATTENDANCE
# ============================================================

class AttendanceCreate(BaseModel):
    student_id: int
    subject_id: int
    attendance_date: date
    status: str
    remarks: str | None = None


class AttendanceUpdate(BaseModel):
    attendance_date: date
    status: str
    remarks: str | None = None


class AttendanceStatusUpdate(BaseModel):
    status: str
    remarks: str | None = None


# ============================================================
# LECTURER ATTENDANCE
# ============================================================

class LecturerAttendanceCreate(BaseModel):
    student_id: int
    subject_id: int
    attendance_date: date
    status: str
    remarks: str | None = None


class LecturerAttendanceUpdate(BaseModel):
    attendance_date: date
    status: str
    remarks: str | None = None

# ============================================================
# LECTURER RESULTS
# ============================================================

class LecturerResultCreate(BaseModel):
    student_id: int
    subject_id: int
    semester: str
    academic_year: str
    marks: float


class LecturerResultUpdate(BaseModel):
    marks: float

# ============================================================
# ADMIN ENROLLMENT MANAGEMENT
# ============================================================

class EnrollmentCreate(BaseModel):
    student_id: int
    subject_id: int
    semester: str
    academic_year: str

