from fastapi import APIRouter, Depends, HTTPException
from backend.database import get_connection
from backend.security import require_role

router = APIRouter(prefix="/student", tags=["Student Services"])


def _student_id_for_user(user_id):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT id FROM students WHERE user_id = %s",
            (user_id,),
        )
        student = cursor.fetchone()

        if not student:
            raise HTTPException(
                status_code=404,
                detail="Student profile not found",
            )

        return student["id"]
    finally:
        cursor.close()
        connection.close()


@router.get("/visa")
def get_student_visa(
    current_user: dict = Depends(require_role("student")),
):
    student_id = _student_id_for_user(current_user["user_id"])

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                id,
                student_id,
                passport_number,
                visa_type,
                visa_status,
                issue_date,
                expiry_date,
                notes
            FROM student_visa
            WHERE student_id = %s
            ORDER BY id DESC
            LIMIT 1
            """,
            (student_id,),
        )

        visa = cursor.fetchone()

        if not visa:
            return {
                "student_id": student_id,
                "visa": None,
            }

        return {
            "student_id": student_id,
            "visa": visa,
        }
    finally:
        cursor.close()
        connection.close()


@router.get("/announcements")
def get_student_announcements(
    current_user: dict = Depends(require_role("student")),
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT *
            FROM announcements
            ORDER BY
                COALESCE(published_at, created_at) DESC,
                id DESC
            """
        )

        return cursor.fetchall()
    finally:
        cursor.close()
        connection.close()
