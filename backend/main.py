import mysql.connector

from fastapi import Body, Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from backend.auth import hash_password, verify_password
from backend.database import get_connection
from backend.schemas import (
    LoginRequest,
    StudentCreate,
    StudentUpdate,
    LecturerCreate,
    LecturerUpdate,
    SubjectCreate,
    SubjectRegistrationCreate,
    SubjectUpdate,
    ResultCreate,
    ResultUpdate,
    ResultPublish,
    AttendanceCreate,
    AttendanceUpdate,
    LecturerAttendanceCreate,
    LecturerAttendanceUpdate,
    LecturerResultCreate,
    LecturerResultUpdate,
    EnrollmentCreate,
)
from backend.security import require_role
from backend.token import create_access_token


# ============================================================
# APPLICATION
# ============================================================

app = FastAPI(
    title="Student Management System API",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# BASIC ROUTES
# ============================================================

@app.get("/")
def root():
    return {
        "message": "Student Management System API is running",
        "status": "online",
    }


@app.get("/health")
def health():
    return {"status": "healthy"}


# ============================================================
# AUTHENTICATION
# ============================================================

@app.post("/login")
def login(login_data: LoginRequest):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id, full_name, email, password_hash, role
            FROM users
            WHERE email = %s
            """,
            (login_data.email,),
        )

        user = cursor.fetchone()

        if not user or not verify_password(
            login_data.password,
            user["password_hash"],
        ):
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password",
            )

        token = create_access_token(
            {
                "user_id": user["id"],
                "role": user["role"],
            }
        )

        return {
            "access_token": token,
            "token_type": "bearer",
            "user_id": user["id"],
            "full_name": user["full_name"],
            "email": user["email"],
            "role": user["role"],
        }

    finally:
        cursor.close()
        connection.close()


# ============================================================
# STUDENTS
# ============================================================

@app.get("/students")
def get_students(
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                s.id,
                s.student_number,
                u.full_name,
                u.email,
                s.date_of_birth,
                s.phone,
                s.address,
                s.program,
                s.enrollment_date
            FROM students s
            JOIN users u
                ON s.user_id = u.id
            ORDER BY s.id DESC
            """
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


@app.get("/students/me")
def get_my_student_profile(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                s.id,
                s.student_number,
                u.full_name,
                u.email,
                s.date_of_birth,
                s.phone,
                s.address,
                s.program,
                s.enrollment_date
            FROM students s
            JOIN users u
                ON s.user_id = u.id
            WHERE s.user_id = %s
            """,
            (current_user["user_id"],),
        )

        student = cursor.fetchone()

        if not student:
            raise HTTPException(
                status_code=404,
                detail="Student profile not found",
            )

        return student

    finally:
        cursor.close()
        connection.close()


@app.get("/students/available-subjects")
def get_available_subjects(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                s.id,
                s.subject_code,
                s.subject_name,
                s.credit_hours,
                s.description,
                s.status
            FROM subjects s
            WHERE s.status = 'active'
              AND NOT EXISTS (
                  SELECT 1
                  FROM student_subjects ss
                  JOIN students st
                      ON ss.student_id = st.id
                  WHERE ss.subject_id = s.id
                    AND st.user_id = %s
                    AND ss.status != 'dropped'
              )
            ORDER BY s.subject_code ASC
            """,
            (current_user["user_id"],),
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


@app.get("/students/{student_id}")
def get_student(
    student_id: int,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                s.id,
                s.student_number,
                u.full_name,
                u.email,
                s.date_of_birth,
                s.phone,
                s.address,
                s.program,
                s.enrollment_date
            FROM students s
            JOIN users u
                ON s.user_id = u.id
            WHERE s.id = %s
            """,
            (student_id,),
        )

        student = cursor.fetchone()

        if not student:
            raise HTTPException(
                status_code=404,
                detail="Student not found",
            )

        return student

    finally:
        cursor.close()
        connection.close()


@app.post("/students", status_code=201)
def create_student(
    student: StudentCreate,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(
            "SELECT id FROM users WHERE email = %s",
            (student.email,),
        )

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Email already exists",
            )

        cursor.execute(
            "SELECT id FROM students WHERE student_number = %s",
            (student.student_number,),
        )

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Student number already exists",
            )

        cursor.execute(
            """
            INSERT INTO users (
                full_name,
                email,
                password_hash,
                role
            )
            VALUES (%s, %s, %s, 'student')
            """,
            (
                student.full_name,
                student.email,
                hash_password(student.password),
            ),
        )

        user_id = cursor.lastrowid

        cursor.execute(
            """
            INSERT INTO students (
                user_id,
                student_number,
                date_of_birth,
                phone,
                address,
                program,
                enrollment_date
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                user_id,
                student.student_number,
                student.date_of_birth,
                student.phone,
                student.address,
                student.program,
                student.enrollment_date,
            ),
        )

        student_id = cursor.lastrowid

        connection.commit()

        return {
            "message": "Student created successfully",
            "student_id": student_id,
            "user_id": user_id,
        }

    except mysql.connector.IntegrityError:
        connection.rollback()

        raise HTTPException(
            status_code=400,
            detail="Student could not be created",
        )

    finally:
        cursor.close()
        connection.close()


@app.put("/students/{student_id}")
def update_student(
    student_id: int,
    student: StudentUpdate,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT user_id FROM students WHERE id = %s",
            (student_id,),
        )

        existing_student = cursor.fetchone()

        if not existing_student:
            raise HTTPException(
                status_code=404,
                detail="Student not found",
            )

        user_id = existing_student["user_id"]

        cursor.execute(
            """
            SELECT id
            FROM users
            WHERE email = %s
              AND id != %s
            """,
            (student.email, user_id),
        )

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Email already exists",
            )

        cursor.execute(
            """
            SELECT id
            FROM students
            WHERE student_number = %s
              AND id != %s
            """,
            (student.student_number, student_id),
        )

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Student number already exists",
            )

        cursor.execute(
            """
            UPDATE users
            SET
                full_name = %s,
                email = %s
            WHERE id = %s
            """,
            (
                student.full_name,
                student.email,
                user_id,
            ),
        )

        cursor.execute(
            """
            UPDATE students
            SET
                student_number = %s,
                date_of_birth = %s,
                phone = %s,
                address = %s,
                program = %s,
                enrollment_date = %s
            WHERE id = %s
            """,
            (
                student.student_number,
                student.date_of_birth,
                student.phone,
                student.address,
                student.program,
                student.enrollment_date,
                student_id,
            ),
        )

        connection.commit()

        return {
            "message": "Student updated successfully",
        }

    except mysql.connector.IntegrityError:
        connection.rollback()

        raise HTTPException(
            status_code=400,
            detail="Student could not be updated",
        )

    finally:
        cursor.close()
        connection.close()


@app.delete("/students/{student_id}")
def delete_student(
    student_id: int,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(
            "SELECT user_id FROM students WHERE id = %s",
            (student_id,),
        )

        student = cursor.fetchone()

        if not student:
            raise HTTPException(
                status_code=404,
                detail="Student not found",
            )

        cursor.execute(
            "DELETE FROM student_subjects WHERE student_id = %s",
            (student_id,),
        )

        cursor.execute(
            "DELETE FROM students WHERE id = %s",
            (student_id,),
        )

        cursor.execute(
            "DELETE FROM users WHERE id = %s",
            (student[0],),
        )

        connection.commit()

        return {
            "message": "Student deleted successfully",
        }

    finally:
        cursor.close()
        connection.close()



# ============================================================
# ADMIN LECTURER MANAGEMENT
# ============================================================

@app.get("/lecturers")
def get_all_lecturers(
    current_user: dict = Depends(require_role("admin"))
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT
                l.id,
                l.user_id,
                u.full_name,
                u.email,
                u.role,
                l.lecturer_number,
                l.department,
                l.phone,
                l.specialization,
                l.hire_date,
                l.created_at
            FROM lecturers l
            JOIN users u ON l.user_id = u.id
            ORDER BY l.id DESC
        """)

        lecturers = cursor.fetchall()
        return lecturers

    finally:
        cursor.close()
        connection.close()


@app.post("/lecturers")
def create_lecturer(
    lecturer: LecturerCreate,
    current_user: dict = Depends(require_role("admin"))
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT id FROM users WHERE email = %s",
            (lecturer.email,)
        )

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Email already exists."
            )

        cursor.execute(
            "SELECT id FROM lecturers WHERE lecturer_number = %s",
            (lecturer.lecturer_number,)
        )

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Lecturer number already exists."
            )

        password_hash = hash_password(lecturer.password)

        cursor.execute("""
            INSERT INTO users
                (full_name, email, password_hash, role)
            VALUES
                (%s, %s, %s, 'lecturer')
        """, (
            lecturer.full_name,
            lecturer.email,
            password_hash
        ))

        user_id = cursor.lastrowid

        cursor.execute("""
            INSERT INTO lecturers
                (
                    user_id,
                    lecturer_number,
                    department,
                    phone,
                    specialization,
                    hire_date
                )
            VALUES
                (%s, %s, %s, %s, %s, %s)
        """, (
            user_id,
            lecturer.lecturer_number,
            lecturer.department,
            lecturer.phone,
            lecturer.specialization,
            lecturer.hire_date
        ))

        lecturer_id = cursor.lastrowid

        connection.commit()

        return {
            "message": "Lecturer created successfully.",
            "lecturer_id": lecturer_id,
            "user_id": user_id
        }

    except HTTPException:
        connection.rollback()
        raise

    except Exception as e:
        connection.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to create lecturer: {str(e)}"
        )

    finally:
        cursor.close()
        connection.close()


@app.put("/lecturers/{lecturer_id}")
def update_lecturer(
    lecturer_id: int,
    lecturer: LecturerUpdate,
    current_user: dict = Depends(require_role("admin"))
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT user_id
            FROM lecturers
            WHERE id = %s
        """, (lecturer_id,))

        existing = cursor.fetchone()

        if not existing:
            raise HTTPException(
                status_code=404,
                detail="Lecturer not found."
            )

        user_id = existing["user_id"]

        cursor.execute("""
            SELECT id
            FROM users
            WHERE email = %s
              AND id != %s
        """, (
            lecturer.email,
            user_id
        ))

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Email already exists."
            )

        cursor.execute("""
            SELECT id
            FROM lecturers
            WHERE lecturer_number = %s
              AND id != %s
        """, (
            lecturer.lecturer_number,
            lecturer_id
        ))

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Lecturer number already exists."
            )

        cursor.execute("""
            UPDATE users
            SET full_name = %s,
                email = %s
            WHERE id = %s
        """, (
            lecturer.full_name,
            lecturer.email,
            user_id
        ))

        cursor.execute("""
            UPDATE lecturers
            SET lecturer_number = %s,
                department = %s,
                phone = %s,
                specialization = %s,
                hire_date = %s
            WHERE id = %s
        """, (
            lecturer.lecturer_number,
            lecturer.department,
            lecturer.phone,
            lecturer.specialization,
            lecturer.hire_date,
            lecturer_id
        ))

        connection.commit()

        return {
            "message": "Lecturer updated successfully."
        }

    except HTTPException:
        connection.rollback()
        raise

    except Exception as e:
        connection.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to update lecturer: {str(e)}"
        )

    finally:
        cursor.close()
        connection.close()


@app.delete("/lecturers/{lecturer_id}")
def delete_lecturer(
    lecturer_id: int,
    current_user: dict = Depends(require_role("admin"))
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT user_id
            FROM lecturers
            WHERE id = %s
        """, (lecturer_id,))

        existing = cursor.fetchone()

        if not existing:
            raise HTTPException(
                status_code=404,
                detail="Lecturer not found."
            )

        user_id = existing["user_id"]

        # Remove subject assignments first.
        cursor.execute("""
            DELETE FROM lecturer_subjects
            WHERE lecturer_id = %s
        """, (lecturer_id,))

        # Remove lecturer profile.
        cursor.execute("""
            DELETE FROM lecturers
            WHERE id = %s
        """, (lecturer_id,))

        # Remove associated user account.
        cursor.execute("""
            DELETE FROM users
            WHERE id = %s
        """, (user_id,))

        connection.commit()

        return {
            "message": "Lecturer deleted successfully."
        }

    except HTTPException:
        connection.rollback()
        raise

    except Exception as e:
        connection.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete lecturer: {str(e)}"
        )

    finally:
        cursor.close()
        connection.close()

# ============================================================
# SUBJECTS
# ============================================================

@app.get("/subjects")
def get_subjects(
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                id,
                subject_code,
                subject_name,
                credit_hours,
                description,
                status,
                created_at
            FROM subjects
            ORDER BY id ASC
            """
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


@app.get("/subjects/{subject_id}")
def get_subject(
    subject_id: int,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                id,
                subject_code,
                subject_name,
                credit_hours,
                description,
                status,
                created_at
            FROM subjects
            WHERE id = %s
            """,
            (subject_id,),
        )

        subject = cursor.fetchone()

        if not subject:
            raise HTTPException(
                status_code=404,
                detail="Subject not found",
            )

        return subject

    finally:
        cursor.close()
        connection.close()


@app.post("/subjects", status_code=201)
def create_subject(
    subject: SubjectCreate,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(
            "SELECT id FROM subjects WHERE subject_code = %s",
            (subject.subject_code,),
        )

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Subject code already exists",
            )

        cursor.execute(
            """
            INSERT INTO subjects (
                subject_code,
                subject_name,
                credit_hours,
                description
            )
            VALUES (%s, %s, %s, %s)
            """,
            (
                subject.subject_code,
                subject.subject_name,
                subject.credit_hours,
                subject.description,
            ),
        )

        subject_id = cursor.lastrowid

        connection.commit()

        return {
            "message": "Subject created successfully",
            "subject_id": subject_id,
        }

    except mysql.connector.IntegrityError:
        connection.rollback()

        raise HTTPException(
            status_code=400,
            detail="Subject could not be created",
        )

    finally:
        cursor.close()
        connection.close()


@app.put("/subjects/{subject_id}")
def update_subject(
    subject_id: int,
    subject: SubjectUpdate,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(
            "SELECT id FROM subjects WHERE id = %s",
            (subject_id,),
        )

        if not cursor.fetchone():
            raise HTTPException(
                status_code=404,
                detail="Subject not found",
            )

        cursor.execute(
            """
            SELECT id
            FROM subjects
            WHERE subject_code = %s
              AND id != %s
            """,
            (subject.subject_code, subject_id),
        )

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Subject code already exists",
            )

        cursor.execute(
            """
            UPDATE subjects
            SET
                subject_code = %s,
                subject_name = %s,
                credit_hours = %s,
                description = %s
            WHERE id = %s
            """,
            (
                subject.subject_code,
                subject.subject_name,
                subject.credit_hours,
                subject.description,
                subject_id,
            ),
        )

        connection.commit()

        return {
            "message": "Subject updated successfully",
        }

    except mysql.connector.IntegrityError:
        connection.rollback()

        raise HTTPException(
            status_code=400,
            detail="Subject could not be updated",
        )

    finally:
        cursor.close()
        connection.close()


@app.delete("/subjects/{subject_id}")
def delete_subject(
    subject_id: int,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(
            "SELECT id FROM subjects WHERE id = %s",
            (subject_id,),
        )

        if not cursor.fetchone():
            raise HTTPException(
                status_code=404,
                detail="Subject not found",
            )

        cursor.execute(
            "DELETE FROM student_subjects WHERE subject_id = %s",
            (subject_id,),
        )

        cursor.execute(
            "DELETE FROM subjects WHERE id = %s",
            (subject_id,),
        )

        connection.commit()

        return {
            "message": "Subject deleted successfully",
        }

    except mysql.connector.IntegrityError:
        connection.rollback()

        raise HTTPException(
            status_code=400,
            detail="Subject cannot be deleted because students are registered for it",
        )

    finally:
        cursor.close()
        connection.close()


# ============================================================
# STUDENT SUBJECT REGISTRATION
# ============================================================

@app.get("/students/me/subjects")
def get_my_subjects(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                ss.id AS registration_id,
                ss.semester,
                ss.academic_year,
                ss.status,
                ss.created_at,
                s.id AS subject_id,
                s.subject_code,
                s.subject_name,
                s.credit_hours,
                s.description
            FROM student_subjects ss
            JOIN students st
                ON ss.student_id = st.id
            JOIN subjects s
                ON ss.subject_id = s.id
            WHERE st.user_id = %s
            ORDER BY ss.created_at DESC
            """,
            (current_user["user_id"],),
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


@app.post("/students/me/subjects", status_code=201)
def register_subject(
    registration: SubjectRegistrationCreate,
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT id FROM students WHERE user_id = %s",
            (current_user["user_id"],),
        )

        student = cursor.fetchone()

        if not student:
            raise HTTPException(
                status_code=404,
                detail="Student profile not found",
            )

        cursor.execute(
            """
            SELECT id, status
            FROM subjects
            WHERE id = %s
            """,
            (registration.subject_id,),
        )

        subject = cursor.fetchone()

        if not subject:
            raise HTTPException(
                status_code=404,
                detail="Subject not found",
            )

        if subject["status"] != "active":
            raise HTTPException(
                status_code=400,
                detail="Subject is not active",
            )

        cursor.execute(
            """
            SELECT id
            FROM student_subjects
            WHERE student_id = %s
              AND subject_id = %s
              AND semester = %s
              AND academic_year = %s
              AND status != 'dropped'
            """,
            (
                student["id"],
                registration.subject_id,
                registration.semester,
                registration.academic_year,
            ),
        )

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="Student is already registered for this subject",
            )

        cursor.execute(
            """
            INSERT INTO student_subjects (
                student_id,
                subject_id,
                semester,
                academic_year,
                status
            )
            VALUES (%s, %s, %s, %s, 'enrolled')
            """,
            (
                student["id"],
                registration.subject_id,
                registration.semester,
                registration.academic_year,
            ),
        )

        registration_id = cursor.lastrowid

        connection.commit()

        return {
            "message": "Subject registered successfully",
            "registration_id": registration_id,
            "subject_id": registration.subject_id,
            "semester": registration.semester,
            "academic_year": registration.academic_year,
            "status": "enrolled",
        }

    except mysql.connector.IntegrityError:
        connection.rollback()

        raise HTTPException(
            status_code=400,
            detail="Student is already registered for this subject",
        )

    finally:
        cursor.close()
        connection.close()


@app.delete("/students/me/subjects/{registration_id}")
def drop_subject(
    registration_id: int,
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT ss.id
            FROM student_subjects ss
            JOIN students st
                ON ss.student_id = st.id
            WHERE ss.id = %s
              AND st.user_id = %s
            """,
            (
                registration_id,
                current_user["user_id"],
            ),
        )

        if not cursor.fetchone():
            raise HTTPException(
                status_code=404,
                detail="Subject registration not found",
            )

        cursor.execute(
            """
            UPDATE student_subjects
            SET status = 'dropped'
            WHERE id = %s
            """,
            (registration_id,),
        )

        connection.commit()

        return {
            "message": "Subject dropped successfully",
            "registration_id": registration_id,
            "status": "dropped",
        }

    finally:
        cursor.close()
        connection.close()


# ============================================================
# ADMIN ENROLLMENT MANAGEMENT
# ============================================================

@app.get("/enrollments")
def get_all_enrollments(
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                ss.id AS enrollment_id,
                ss.student_id,
                st.student_number,
                u.full_name AS student_name,
                u.email AS student_email,
                ss.subject_id,
                s.subject_code,
                s.subject_name,
                ss.semester,
                ss.academic_year,
                ss.status,
                ss.created_at
            FROM student_subjects ss
            JOIN students st
                ON ss.student_id = st.id
            JOIN users u
                ON st.user_id = u.id
            JOIN subjects s
                ON ss.subject_id = s.id
            ORDER BY ss.created_at DESC
            """
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


@app.post("/enrollments", status_code=201)
def create_enrollment(
    enrollment: EnrollmentCreate,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        # Verify student exists.
        cursor.execute(
            """
            SELECT
                st.id,
                st.student_number,
                u.full_name
            FROM students st
            JOIN users u
                ON st.user_id = u.id
            WHERE st.id = %s
            """,
            (enrollment.student_id,),
        )

        student = cursor.fetchone()

        if not student:
            raise HTTPException(
                status_code=404,
                detail="Student not found",
            )

        # Verify subject exists and is active.
        cursor.execute(
            """
            SELECT
                id,
                subject_code,
                subject_name,
                status
            FROM subjects
            WHERE id = %s
            """,
            (enrollment.subject_id,),
        )

        subject = cursor.fetchone()

        if not subject:
            raise HTTPException(
                status_code=404,
                detail="Subject not found",
            )

        if subject["status"] != "active":
            raise HTTPException(
                status_code=400,
                detail="Subject is not active",
            )

        # Prevent duplicate active/completed enrollment.
        cursor.execute(
            """
            SELECT id, status
            FROM student_subjects
            WHERE student_id = %s
              AND subject_id = %s
              AND semester = %s
              AND academic_year = %s
              AND status != 'dropped'
            """,
            (
                enrollment.student_id,
                enrollment.subject_id,
                enrollment.semester,
                enrollment.academic_year,
            ),
        )

        existing = cursor.fetchone()

        if existing:
            raise HTTPException(
                status_code=400,
                detail="Student is already enrolled in this subject",
            )

        cursor.execute(
            """
            INSERT INTO student_subjects (
                student_id,
                subject_id,
                semester,
                academic_year,
                status
            )
            VALUES (%s, %s, %s, %s, 'enrolled')
            """,
            (
                enrollment.student_id,
                enrollment.subject_id,
                enrollment.semester,
                enrollment.academic_year,
            ),
        )

        enrollment_id = cursor.lastrowid

        connection.commit()

        return {
            "message": "Student enrolled successfully",
            "enrollment_id": enrollment_id,
            "student_id": enrollment.student_id,
            "subject_id": enrollment.subject_id,
            "semester": enrollment.semester,
            "academic_year": enrollment.academic_year,
            "status": "enrolled",
        }

    except mysql.connector.IntegrityError:
        connection.rollback()

        raise HTTPException(
            status_code=400,
            detail="Unable to create enrollment",
        )

    finally:
        cursor.close()
        connection.close()


@app.delete("/enrollments/{enrollment_id}")
def delete_enrollment(
    enrollment_id: int,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id
            FROM student_subjects
            WHERE id = %s
            """,
            (enrollment_id,),
        )

        enrollment = cursor.fetchone()

        if not enrollment:
            raise HTTPException(
                status_code=404,
                detail="Enrollment not found",
            )

        cursor.execute(
            """
            UPDATE student_subjects
            SET status = 'dropped'
            WHERE id = %s
            """,
            (enrollment_id,),
        )

        connection.commit()

        return {
            "message": "Enrollment removed successfully",
            "enrollment_id": enrollment_id,
            "status": "dropped",
        }

    finally:
        cursor.close()
        connection.close()


# ============================================================
# ATTENDANCE
# ============================================================

@app.get("/attendance")
def get_all_attendance(
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                a.id,
                a.student_id,
                st.student_number,
                u.full_name AS student_name,
                a.subject_id,
                s.subject_code,
                s.subject_name,
                a.attendance_date,
                a.status,
                a.remarks,
                a.created_at
            FROM attendance a
            JOIN students st
                ON a.student_id = st.id
            JOIN users u
                ON st.user_id = u.id
            JOIN subjects s
                ON a.subject_id = s.id
            ORDER BY a.attendance_date DESC, a.id DESC
            """
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


@app.get("/attendance/{attendance_id}")
def get_attendance(
    attendance_id: int,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                a.id,
                a.student_id,
                st.student_number,
                u.full_name AS student_name,
                a.subject_id,
                s.subject_code,
                s.subject_name,
                a.attendance_date,
                a.status,
                a.remarks,
                a.created_at
            FROM attendance a
            JOIN students st
                ON a.student_id = st.id
            JOIN users u
                ON st.user_id = u.id
            JOIN subjects s
                ON a.subject_id = s.id
            WHERE a.id = %s
            """,
            (attendance_id,),
        )

        attendance = cursor.fetchone()

        if not attendance:
            raise HTTPException(
                status_code=404,
                detail="Attendance record not found",
            )

        return attendance

    finally:
        cursor.close()
        connection.close()


@app.post("/attendance", status_code=201)
def create_attendance(
    attendance: AttendanceCreate,
    current_user: dict = Depends(require_role("admin")),
):
    if attendance.status not in ["present", "absent", "late"]:
        raise HTTPException(
            status_code=400,
            detail="Invalid attendance status",
        )

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id
            FROM students
            WHERE id = %s
            """,
            (attendance.student_id,),
        )

        student = cursor.fetchone()

        if not student:
            raise HTTPException(
                status_code=404,
                detail="Student not found",
            )

        cursor.execute(
            """
            SELECT id
            FROM subjects
            WHERE id = %s
              AND status = 'active'
            """,
            (attendance.subject_id,),
        )

        subject = cursor.fetchone()

        if not subject:
            raise HTTPException(
                status_code=404,
                detail="Active subject not found",
            )

        cursor.execute(
            """
            SELECT id
            FROM student_subjects
            WHERE student_id = %s
              AND subject_id = %s
              AND status = 'enrolled'
            """,
            (
                attendance.student_id,
                attendance.subject_id,
            ),
        )

        registration = cursor.fetchone()

        if not registration:
            raise HTTPException(
                status_code=400,
                detail="Student is not enrolled in this subject",
            )

        cursor.execute(
            """
            SELECT id
            FROM attendance
            WHERE student_id = %s
              AND subject_id = %s
              AND attendance_date = %s
            """,
            (
                attendance.student_id,
                attendance.subject_id,
                attendance.attendance_date,
            ),
        )

        existing = cursor.fetchone()

        if existing:
            raise HTTPException(
                status_code=400,
                detail="Attendance already recorded for this date",
            )

        cursor.execute(
            """
            INSERT INTO attendance (
                student_id,
                subject_id,
                attendance_date,
                status,
                remarks
            )
            VALUES (%s, %s, %s, %s, %s)
            """,
            (
                attendance.student_id,
                attendance.subject_id,
                attendance.attendance_date,
                attendance.status,
                attendance.remarks,
            ),
        )

        connection.commit()

        return {
            "message": "Attendance recorded successfully",
            "attendance_id": cursor.lastrowid,
            "student_id": attendance.student_id,
            "subject_id": attendance.subject_id,
            "attendance_date": attendance.attendance_date,
            "status": attendance.status,
            "remarks": attendance.remarks,
        }

    finally:
        cursor.close()
        connection.close()


@app.put("/attendance/{attendance_id}")
def update_attendance(
    attendance_id: int,
    attendance: AttendanceUpdate,
    current_user: dict = Depends(require_role("admin")),
):
    if attendance.status not in ["present", "absent", "late"]:
        raise HTTPException(
            status_code=400,
            detail="Invalid attendance status",
        )

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id
            FROM attendance
            WHERE id = %s
            """,
            (attendance_id,),
        )

        existing = cursor.fetchone()

        if not existing:
            raise HTTPException(
                status_code=404,
                detail="Attendance record not found",
            )

        cursor.execute(
            """
            UPDATE attendance
            SET
                attendance_date = %s,
                status = %s,
                remarks = %s
            WHERE id = %s
            """,
            (
                attendance.attendance_date,
                attendance.status,
                attendance.remarks,
                attendance_id,
            ),
        )

        connection.commit()

        return {
            "message": "Attendance updated successfully",
            "attendance_id": attendance_id,
            "attendance_date": attendance.attendance_date,
            "status": attendance.status,
            "remarks": attendance.remarks,
        }

    finally:
        cursor.close()
        connection.close()


@app.delete("/attendance/{attendance_id}")
def delete_attendance(
    attendance_id: int,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id
            FROM attendance
            WHERE id = %s
            """,
            (attendance_id,),
        )

        existing = cursor.fetchone()

        if not existing:
            raise HTTPException(
                status_code=404,
                detail="Attendance record not found",
            )

        cursor.execute(
            """
            DELETE FROM attendance
            WHERE id = %s
            """,
            (attendance_id,),
        )

        connection.commit()

        return {
            "message": "Attendance deleted successfully",
            "attendance_id": attendance_id,
        }

    finally:
        cursor.close()
        connection.close()


# ============================================================
# STUDENT ATTENDANCE
# ============================================================

@app.get("/students/me/attendance")
def get_my_attendance(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                a.id,
                a.attendance_date,
                a.status,
                a.remarks,
                a.subject_id,
                s.subject_code,
                s.subject_name,
                s.credit_hours
            FROM attendance a
            JOIN students st
                ON a.student_id = st.id
            JOIN subjects s
                ON a.subject_id = s.id
            WHERE st.user_id = %s
            ORDER BY a.attendance_date DESC, a.id DESC
            """,
            (current_user["user_id"],),
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


@app.get("/students/me/attendance/summary")
def get_my_attendance_summary(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                COUNT(*) AS total_classes,
                SUM(
                    CASE
                        WHEN a.status = 'present'
                        THEN 1
                        ELSE 0
                    END
                ) AS present_classes,
                SUM(
                    CASE
                        WHEN a.status = 'absent'
                        THEN 1
                        ELSE 0
                    END
                ) AS absent_classes,
                SUM(
                    CASE
                        WHEN a.status = 'late'
                        THEN 1
                        ELSE 0
                    END
                ) AS late_classes
            FROM attendance a
            JOIN students st
                ON a.student_id = st.id
            WHERE st.user_id = %s
            """,
            (current_user["user_id"],),
        )

        summary = cursor.fetchone()

        total_classes = int(summary["total_classes"] or 0)
        present_classes = int(summary["present_classes"] or 0)
        absent_classes = int(summary["absent_classes"] or 0)
        late_classes = int(summary["late_classes"] or 0)

        attendance_percentage = (
            (present_classes / total_classes) * 100
            if total_classes > 0
            else 0
        )

        return {
            "total_classes": total_classes,
            "present_classes": present_classes,
            "absent_classes": absent_classes,
            "late_classes": late_classes,
            "attendance_percentage": round(
                attendance_percentage,
                2,
            ),
        }

    finally:
        cursor.close()
        connection.close()


# ============================================================
# RESULTS
# ============================================================

def calculate_grade(marks: float):
    if marks >= 80:
        return "A", 4.00
    elif marks >= 75:
        return "A-", 3.75
    elif marks >= 70:
        return "B+", 3.50
    elif marks >= 65:
        return "B", 3.00
    elif marks >= 60:
        return "B-", 2.75
    elif marks >= 55:
        return "C+", 2.50
    elif marks >= 50:
        return "C", 2.00
    elif marks >= 45:
        return "D", 1.00
    else:
        return "F", 0.00


@app.get("/results")
def get_results(
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                r.id,
                r.student_id,
                r.subject_id,
                s.student_number,
                u.full_name AS student_name,
                sub.subject_code,
                sub.subject_name,
                sub.credit_hours,
                r.semester,
                r.academic_year,
                r.marks,
                r.grade,
                r.grade_point,
                r.status,
                r.created_at,
                r.updated_at
            FROM results r
            JOIN students s
                ON r.student_id = s.id
            JOIN users u
                ON s.user_id = u.id
            JOIN subjects sub
                ON r.subject_id = sub.id
            ORDER BY
                r.academic_year DESC,
                r.semester,
                u.full_name
            """
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


@app.get("/results/{result_id}")
def get_result(
    result_id: int,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                r.id,
                r.student_id,
                r.subject_id,
                s.student_number,
                u.full_name AS student_name,
                sub.subject_code,
                sub.subject_name,
                sub.credit_hours,
                r.semester,
                r.academic_year,
                r.marks,
                r.grade,
                r.grade_point,
                r.status,
                r.created_at,
                r.updated_at
            FROM results r
            JOIN students s
                ON r.student_id = s.id
            JOIN users u
                ON s.user_id = u.id
            JOIN subjects sub
                ON r.subject_id = sub.id
            WHERE r.id = %s
            """,
            (result_id,),
        )

        result = cursor.fetchone()

        if not result:
            raise HTTPException(
                status_code=404,
                detail="Result not found",
            )

        return result

    finally:
        cursor.close()
        connection.close()


@app.post("/results", status_code=201)
def create_result(
    result: ResultCreate,
    current_user: dict = Depends(require_role("admin")),
):
    if result.marks < 0 or result.marks > 100:
        raise HTTPException(
            status_code=400,
            detail="Marks must be between 0 and 100",
        )

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id
            FROM students
            WHERE id = %s
            """,
            (result.student_id,),
        )

        student = cursor.fetchone()

        if not student:
            raise HTTPException(
                status_code=404,
                detail="Student not found",
            )

        cursor.execute(
            """
            SELECT id
            FROM subjects
            WHERE id = %s
            """,
            (result.subject_id,),
        )

        subject = cursor.fetchone()

        if not subject:
            raise HTTPException(
                status_code=404,
                detail="Subject not found",
            )

        cursor.execute(
            """
            SELECT id
            FROM results
            WHERE student_id = %s
              AND subject_id = %s
              AND semester = %s
              AND academic_year = %s
            """,
            (
                result.student_id,
                result.subject_id,
                result.semester,
                result.academic_year,
            ),
        )

        existing_result = cursor.fetchone()

        if existing_result:
            raise HTTPException(
                status_code=400,
                detail="Result already exists for this student and subject",
            )

        grade, grade_point = calculate_grade(result.marks)

        cursor.execute(
            """
            INSERT INTO results (
                student_id,
                subject_id,
                semester,
                academic_year,
                marks,
                grade,
                grade_point,
                status
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, 'draft')
            """,
            (
                result.student_id,
                result.subject_id,
                result.semester,
                result.academic_year,
                result.marks,
                grade,
                grade_point,
            ),
        )

        connection.commit()

        return {
            "message": "Result created successfully",
            "result_id": cursor.lastrowid,
            "student_id": result.student_id,
            "subject_id": result.subject_id,
            "semester": result.semester,
            "academic_year": result.academic_year,
            "marks": result.marks,
            "grade": grade,
            "grade_point": grade_point,
            "status": "draft",
        }

    finally:
        cursor.close()
        connection.close()


# ============================================================
# ADMIN DELETE RESULT
# ============================================================

@app.delete("/results/{result_id}")
def delete_result(
    result_id: int,
    current_user: dict = Depends(require_role("admin")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id
            FROM results
            WHERE id = %s
            """,
            (result_id,),
        )

        existing_result = cursor.fetchone()

        if not existing_result:
            raise HTTPException(
                status_code=404,
                detail="Result not found",
            )

        cursor.execute(
            """
            DELETE FROM results
            WHERE id = %s
            """,
            (result_id,),
        )

        connection.commit()

        return {
            "message": "Result deleted successfully",
            "id": result_id,
        }

    except HTTPException:
        raise

    except Exception as e:
        connection.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete result: {str(e)}",
        )

    finally:
        cursor.close()
        connection.close()


@app.put("/results/{result_id}")
def update_result(
    result_id: int,
    result: ResultUpdate,
    current_user: dict = Depends(require_role("admin")),
):
    if result.marks < 0 or result.marks > 100:
        raise HTTPException(
            status_code=400,
            detail="Marks must be between 0 and 100",
        )

    if result.status not in ["draft", "published"]:
        raise HTTPException(
            status_code=400,
            detail="Status must be either draft or published",
        )

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id
            FROM results
            WHERE id = %s
            """,
            (result_id,),
        )

        existing_result = cursor.fetchone()

        if not existing_result:
            raise HTTPException(
                status_code=404,
                detail="Result not found",
            )

        grade, grade_point = calculate_grade(result.marks)

        cursor.execute(
            """
            UPDATE results
            SET
                marks = %s,
                grade = %s,
                grade_point = %s,
                status = %s
            WHERE id = %s
            """,
            (
                result.marks,
                grade,
                grade_point,
                result.status,
                result_id,
            ),
        )

        connection.commit()

        return {
            "message": "Result updated successfully",
            "result_id": result_id,
            "marks": result.marks,
            "grade": grade,
            "grade_point": grade_point,
            "status": result.status,
        }

    finally:
        cursor.close()
        connection.close()


@app.put("/results/{result_id}/publish")
def publish_result(
    result_id: int,
    result: ResultPublish,
    current_user: dict = Depends(require_role("admin")),
):
    if result.status not in ["draft", "published"]:
        raise HTTPException(
            status_code=400,
            detail="Status must be either draft or published",
        )

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id
            FROM results
            WHERE id = %s
            """,
            (result_id,),
        )

        existing_result = cursor.fetchone()

        if not existing_result:
            raise HTTPException(
                status_code=404,
                detail="Result not found",
            )

        cursor.execute(
            """
            UPDATE results
            SET status = %s
            WHERE id = %s
            """,
            (
                result.status,
                result_id,
            ),
        )

        connection.commit()

        return {
            "message": "Result status updated successfully",
            "result_id": result_id,
            "status": result.status,
        }

    finally:
        cursor.close()
        connection.close()


@app.get("/students/me/results")
def get_my_results(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                r.id,
                r.semester,
                r.academic_year,
                r.marks,
                r.grade,
                r.grade_point,
                r.status,
                sub.id AS subject_id,
                sub.subject_code,
                sub.subject_name,
                sub.credit_hours
            FROM results r
            JOIN students s
                ON r.student_id = s.id
            JOIN subjects sub
                ON r.subject_id = sub.id
            WHERE s.user_id = %s
              AND r.status = 'published'
            ORDER BY
                r.academic_year DESC,
                r.semester,
                sub.subject_code
            """,
            (current_user["user_id"],),
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


# ============================================================
# GPA / CGPA
# ============================================================

@app.get("/students/me/gpa")
def get_my_gpa(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                r.semester,
                r.academic_year,
                r.grade_point,
                s.credit_hours
            FROM results r
            JOIN students st
                ON r.student_id = st.id
            JOIN subjects s
                ON r.subject_id = s.id
            WHERE st.user_id = %s
              AND r.status = 'published'
            ORDER BY
                r.academic_year,
                r.semester,
                r.id
            """,
            (current_user["user_id"],),
        )

        results = cursor.fetchall()
        semesters = {}

        for result in results:
            semester_key = (
                result["semester"],
                result["academic_year"],
            )

            if semester_key not in semesters:
                semesters[semester_key] = {
                    "semester": result["semester"],
                    "academic_year": result["academic_year"],
                    "total_credit_hours": 0,
                    "total_grade_points": 0,
                }

            credit_hours = result["credit_hours"]
            grade_point = float(result["grade_point"])

            semesters[semester_key]["total_credit_hours"] += credit_hours
            semesters[semester_key]["total_grade_points"] += (
                credit_hours * grade_point
            )

        semester_results = []

        for semester_data in semesters.values():
            total_credits = semester_data["total_credit_hours"]
            total_grade_points = semester_data["total_grade_points"]

            gpa = (
                total_grade_points / total_credits
                if total_credits > 0
                else 0
            )

            semester_results.append(
                {
                    "semester": semester_data["semester"],
                    "academic_year": semester_data["academic_year"],
                    "total_credit_hours": total_credits,
                    "gpa": round(gpa, 2),
                }
            )

        return semester_results

    finally:
        cursor.close()
        connection.close()


@app.get("/students/me/cgpa")
def get_my_cgpa(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                r.grade_point,
                s.credit_hours
            FROM results r
            JOIN students st
                ON r.student_id = st.id
            JOIN subjects s
                ON r.subject_id = s.id
            WHERE st.user_id = %s
              AND r.status = 'published'
            """,
            (current_user["user_id"],),
        )

        results = cursor.fetchall()

        total_credit_hours = 0
        total_grade_points = 0

        for result in results:
            credit_hours = result["credit_hours"]
            grade_point = float(result["grade_point"])

            total_credit_hours += credit_hours
            total_grade_points += credit_hours * grade_point

        cgpa = (
            total_grade_points / total_credit_hours
            if total_credit_hours > 0
            else 0
        )

        return {
            "total_credit_hours": total_credit_hours,
            "cgpa": round(cgpa, 2),
        }

    finally:
        cursor.close()
        connection.close()


# ============================================================
# ACADEMIC PERFORMANCE
# ============================================================

@app.get("/students/me/performance")
def get_my_performance(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                r.marks,
                r.grade,
                r.grade_point,
                s.credit_hours
            FROM results r
            JOIN students st
                ON r.student_id = st.id
            JOIN subjects s
                ON r.subject_id = s.id
            WHERE st.user_id = %s
              AND r.status = 'published'
            ORDER BY r.created_at ASC
            """,
            (current_user["user_id"],),
        )

        results = cursor.fetchall()

        total_subjects = len(results)
        passed_subjects = 0
        failed_subjects = 0
        total_credit_hours = 0
        total_marks = 0.0

        for result in results:
            marks = float(result["marks"])
            credit_hours = int(result["credit_hours"])

            total_marks += marks
            total_credit_hours += credit_hours

            if result["grade"] == "F":
                failed_subjects += 1
            else:
                passed_subjects += 1

        average_marks = (
            total_marks / total_subjects
            if total_subjects > 0
            else 0.0
        )

        cursor.execute(
            """
            SELECT
                COALESCE(
                    SUM(r.grade_point * s.credit_hours)
                    / NULLIF(SUM(s.credit_hours), 0),
                    0
                ) AS cgpa
            FROM results r
            JOIN students st
                ON r.student_id = st.id
            JOIN subjects s
                ON r.subject_id = s.id
            WHERE st.user_id = %s
              AND r.status = 'published'
            """,
            (current_user["user_id"],),
        )

        cgpa_result = cursor.fetchone()

        cgpa = (
            float(cgpa_result["cgpa"])
            if cgpa_result
            and cgpa_result["cgpa"] is not None
            else 0.0
        )

        if failed_subjects > 0:
            academic_status = "At Risk"
        elif cgpa >= 3.50:
            academic_status = "Excellent"
        elif cgpa >= 3.00:
            academic_status = "Good"
        elif cgpa >= 2.00:
            academic_status = "Satisfactory"
        else:
            academic_status = "Needs Improvement"

        return {
            "cgpa": round(cgpa, 2),
            "total_credit_hours": total_credit_hours,
            "total_subjects": total_subjects,
            "passed_subjects": passed_subjects,
            "failed_subjects": failed_subjects,
            "average_marks": round(average_marks, 2),
            "academic_status": academic_status,
        }

    finally:
        cursor.close()
        connection.close()

# ============================================================
# LECTURERS
# ============================================================

@app.get("/lecturers/me")
def get_my_lecturer_profile(
    current_user: dict = Depends(require_role("lecturer")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                l.id,
                l.lecturer_number,
                u.full_name,
                u.email,
                l.department,
                l.phone,
                l.specialization,
                l.hire_date
            FROM lecturers l
            JOIN users u
                ON l.user_id = u.id
            WHERE l.user_id = %s
            """,
            (current_user["user_id"],),
        )

        lecturer = cursor.fetchone()

        if not lecturer:
            raise HTTPException(
                status_code=404,
                detail="Lecturer profile not found",
            )

        return lecturer

    finally:
        cursor.close()
        connection.close()

@app.get("/lecturers/me/subjects")
def get_my_lecturer_subjects(
    current_user: dict = Depends(require_role("lecturer")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                ls.id AS assignment_id,
                s.id AS subject_id,
                s.subject_code,
                s.subject_name,
                s.credit_hours,
                s.description,
                ls.academic_year,
                ls.semester
            FROM lecturer_subjects ls
            JOIN lecturers l
                ON ls.lecturer_id = l.id
            JOIN subjects s
                ON ls.subject_id = s.id
            WHERE l.user_id = %s
            ORDER BY ls.academic_year DESC, ls.semester, s.subject_code
            """,
            (current_user["user_id"],),
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()

@app.get("/lecturers/me/subjects/{subject_id}/students")
def get_students_for_lecturer_subject(
    subject_id: int,
    current_user: dict = Depends(require_role("lecturer")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        # ----------------------------------------------------
        # Verify that this subject is assigned to the lecturer
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                ls.id AS assignment_id,
                s.id AS subject_id,
                s.subject_code,
                s.subject_name,
                ls.academic_year,
                ls.semester
            FROM lecturer_subjects ls
            JOIN lecturers l
                ON ls.lecturer_id = l.id
            JOIN subjects s
                ON ls.subject_id = s.id
            WHERE l.user_id = %s
              AND s.id = %s
            """,
            (current_user["user_id"], subject_id),
        )

        assignment = cursor.fetchone()

        if not assignment:
            raise HTTPException(
                status_code=403,
                detail="This subject is not assigned to you",
            )

        # ----------------------------------------------------
        # Get students enrolled in this subject
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                ss.id AS registration_id,
                st.id AS student_id,
                st.student_number,
                u.full_name,
                u.email,
                st.program,
                ss.semester,
                ss.academic_year,
                ss.status
            FROM student_subjects ss
            JOIN students st
                ON ss.student_id = st.id
            JOIN users u
                ON st.user_id = u.id
            WHERE ss.subject_id = %s
            ORDER BY st.student_number
            """,
            (subject_id,),
        )

        students = cursor.fetchall()

        return {
            "subject": assignment,
            "students": students,
        }

    finally:
        cursor.close()
        connection.close()

# ============================================================
# LECTURER ATTENDANCE
# ============================================================

@app.post("/lecturers/me/attendance")
def create_lecturer_attendance(
    attendance: LecturerAttendanceCreate = Body(...),
    current_user: dict = Depends(require_role("lecturer")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        # ----------------------------------------------------
        # Verify lecturer is assigned to this subject
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                ls.id AS assignment_id,
                l.id AS lecturer_id
            FROM lecturer_subjects ls
            JOIN lecturers l
                ON ls.lecturer_id = l.id
            WHERE l.user_id = %s
              AND ls.subject_id = %s
            """,
            (current_user["user_id"], attendance.subject_id),
        )

        assignment = cursor.fetchone()

        if not assignment:
            raise HTTPException(
                status_code=403,
                detail="This subject is not assigned to you",
            )

        # ----------------------------------------------------
        # Verify student exists and is enrolled in subject
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                ss.id AS registration_id
            FROM student_subjects ss
            JOIN students st
                ON ss.student_id = st.id
            WHERE ss.student_id = %s
              AND ss.subject_id = %s
              AND ss.status = 'enrolled'
            """,
            (attendance.student_id, attendance.subject_id),
        )

        enrollment = cursor.fetchone()

        if not enrollment:
            raise HTTPException(
                status_code=400,
                detail="Student is not enrolled in this subject",
            )

        # ----------------------------------------------------
        # Validate attendance status
        # ----------------------------------------------------
        valid_statuses = {"present", "absent", "late"}

        if attendance.status not in valid_statuses:
            raise HTTPException(
                status_code=400,
                detail="Invalid attendance status",
            )

        # ----------------------------------------------------
        # Prevent duplicate attendance
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT id
            FROM attendance
            WHERE student_id = %s
              AND subject_id = %s
              AND attendance_date = %s
            """,
            (
                attendance.student_id,
                attendance.subject_id,
                attendance.attendance_date,
            ),
        )

        existing = cursor.fetchone()

        if existing:
            raise HTTPException(
                status_code=400,
                detail="Attendance already recorded for this date",
            )

        # ----------------------------------------------------
        # Insert attendance
        # ----------------------------------------------------
        cursor.execute(
            """
            INSERT INTO attendance (
                student_id,
                subject_id,
                attendance_date,
                status,
                remarks
            )
            VALUES (%s, %s, %s, %s, %s)
            """,
            (
                attendance.student_id,
                attendance.subject_id,
                attendance.attendance_date,
                attendance.status,
                attendance.remarks,
            ),
        )

        connection.commit()

        attendance_id = cursor.lastrowid

        return {
            "message": "Attendance recorded successfully",
            "attendance_id": attendance_id,
        }

    finally:
        cursor.close()
        connection.close()

# ============================================================
# LECTURER RESULTS
# ============================================================

@app.post("/lecturers/me/results")
def create_lecturer_result(
    result: LecturerResultCreate = Body(...),
    current_user: dict = Depends(require_role("lecturer")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        # ----------------------------------------------------
        # Verify lecturer is assigned to this subject
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                ls.id AS assignment_id,
                l.id AS lecturer_id
            FROM lecturer_subjects ls
            JOIN lecturers l
                ON ls.lecturer_id = l.id
            WHERE l.user_id = %s
              AND ls.subject_id = %s
              AND ls.semester = %s
              AND ls.academic_year = %s
            """,
            (
                current_user["user_id"],
                result.subject_id,
                result.semester,
                result.academic_year,
            ),
        )

        assignment = cursor.fetchone()

        if not assignment:
            raise HTTPException(
                status_code=403,
                detail="This subject is not assigned to you",
            )

        # ----------------------------------------------------
        # Verify student is enrolled in this subject
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                ss.id AS registration_id
            FROM student_subjects ss
            WHERE ss.student_id = %s
              AND ss.subject_id = %s
              AND ss.semester = %s
              AND ss.academic_year = %s
              AND ss.status = 'enrolled'
            """,
            (
                result.student_id,
                result.subject_id,
                result.semester,
                result.academic_year,
            ),
        )

        enrollment = cursor.fetchone()

        if not enrollment:
            raise HTTPException(
                status_code=400,
                detail="Student is not enrolled in this subject",
            )

        # ----------------------------------------------------
        # Validate marks
        # ----------------------------------------------------
        if result.marks < 0 or result.marks > 100:
            raise HTTPException(
                status_code=400,
                detail="Marks must be between 0 and 100",
            )

        # ----------------------------------------------------
        # Calculate grade and grade point
        # ----------------------------------------------------
        grade, grade_point = calculate_grade(result.marks)

        # ----------------------------------------------------
        # Prevent duplicate result
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT id
            FROM results
            WHERE student_id = %s
              AND subject_id = %s
              AND semester = %s
              AND academic_year = %s
            """,
            (
                result.student_id,
                result.subject_id,
                result.semester,
                result.academic_year,
            ),
        )

        existing = cursor.fetchone()

        if existing:
            raise HTTPException(
                status_code=400,
                detail="Result already exists for this student and subject",
            )

        # ----------------------------------------------------
        # Insert result
        # ----------------------------------------------------
        cursor.execute(
            """
            INSERT INTO results (
                student_id,
                subject_id,
                semester,
                academic_year,
                marks,
                grade,
                grade_point,
                status
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, 'draft')
            """,
            (
                result.student_id,
                result.subject_id,
                result.semester,
                result.academic_year,
                result.marks,
                grade,
                grade_point,
            ),
        )

        connection.commit()

        result_id = cursor.lastrowid

        return {
            "message": "Result created successfully",
            "result_id": result_id,
            "marks": result.marks,
            "grade": grade,
            "grade_point": grade_point,
            "status": "draft",
        }

    finally:
        cursor.close()
        connection.close()

# ============================================================
# LECTURER RESULTS - VIEW
# ============================================================

@app.get("/lecturers/me/results")
def get_my_lecturer_results(
    current_user: dict = Depends(require_role("lecturer")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                r.id AS result_id,
                r.student_id,
                st.student_number,
                u.full_name AS student_name,
                u.email AS student_email,
                r.subject_id,
                s.subject_code,
                s.subject_name,
                s.credit_hours,
                r.semester,
                r.academic_year,
                r.marks,
                r.grade,
                r.grade_point,
                r.status,
                r.created_at,
                r.updated_at
            FROM results r
            JOIN students st
                ON r.student_id = st.id
            JOIN users u
                ON st.user_id = u.id
            JOIN subjects s
                ON r.subject_id = s.id
            JOIN lecturer_subjects ls
                ON r.subject_id = ls.subject_id
                AND r.semester = ls.semester
                AND r.academic_year = ls.academic_year
            JOIN lecturers l
                ON ls.lecturer_id = l.id
            WHERE l.user_id = %s
            ORDER BY
                r.academic_year DESC,
                r.semester,
                s.subject_code,
                st.student_number
            """,
            (current_user["user_id"],),
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


# ============================================================
# LECTURER RESULTS - UPDATE DRAFT
# ============================================================

@app.put("/lecturers/me/results/{result_id}")
def update_lecturer_result(
    result_id: int,
    result: LecturerResultUpdate = Body(...),
    current_user: dict = Depends(require_role("lecturer")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        # ----------------------------------------------------
        # Get result and verify lecturer owns the subject
        # ----------------------------------------------------
        cursor.execute(
            """
            SELECT
                r.id,
                r.student_id,
                r.subject_id,
                r.semester,
                r.academic_year,
                r.status,
                ls.id AS assignment_id
            FROM results r
            JOIN lecturer_subjects ls
                ON r.subject_id = ls.subject_id
                AND r.semester = ls.semester
                AND r.academic_year = ls.academic_year
            JOIN lecturers l
                ON ls.lecturer_id = l.id
            WHERE r.id = %s
              AND l.user_id = %s
            """,
            (
                result_id,
                current_user["user_id"],
            ),
        )

        existing_result = cursor.fetchone()

        if not existing_result:
            raise HTTPException(
                status_code=404,
                detail="Result not found or you are not assigned to this subject",
            )

        # ----------------------------------------------------
        # Prevent modification of published results
        # ----------------------------------------------------
        if existing_result["status"] == "published":
            raise HTTPException(
                status_code=403,
                detail="Published results cannot be modified",
            )

        # ----------------------------------------------------
        # Validate marks
        # ----------------------------------------------------
        if result.marks < 0 or result.marks > 100:
            raise HTTPException(
                status_code=400,
                detail="Marks must be between 0 and 100",
            )

        # ----------------------------------------------------
        # Calculate grade and grade point
        # ----------------------------------------------------
        grade, grade_point = calculate_grade(result.marks)

        # ----------------------------------------------------
        # Update result
        # ----------------------------------------------------
        cursor.execute(
            """
            UPDATE results
            SET
                marks = %s,
                grade = %s,
                grade_point = %s
            WHERE id = %s
            """,
            (
                result.marks,
                grade,
                grade_point,
                result_id,
            ),
        )

        connection.commit()

        return {
            "message": "Result updated successfully",
            "result_id": result_id,
            "marks": result.marks,
            "grade": grade,
            "grade_point": grade_point,
            "status": existing_result["status"],
        }

    finally:
        cursor.close()
        connection.close()