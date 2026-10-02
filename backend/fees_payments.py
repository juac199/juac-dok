from datetime import date
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException

from backend.database import get_connection
from backend.security import get_current_user


router = APIRouter(
    prefix="/student/fees",
    tags=["Student Fees & Payments"],
)


def money(value):
    if value is None:
        return 0.0
    return float(Decimal(str(value)))


@router.get("/summary")
def get_fee_summary(current_user: dict = Depends(get_current_user)):
    if current_user.get("role") != "student":
        raise HTTPException(status_code=403, detail="Student access required")

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT s.id AS student_id
            FROM students s
            WHERE s.user_id = %s
            LIMIT 1
        """, (current_user["user_id"],))

        student = cursor.fetchone()

        if not student:
            raise HTTPException(status_code=404, detail="Student record not found")

        student_id = student["student_id"]

        cursor.execute("""
            SELECT
                COALESCE(SUM(i.amount), 0) AS total_fees,
                COALESCE((
                    SELECT SUM(p.amount)
                    FROM fee_payments p
                    WHERE p.student_id = %s
                      AND p.payment_status = 'successful'
                ), 0) AS amount_paid
            FROM fee_invoices i
            WHERE i.student_id = %s
              AND i.status <> 'cancelled'
        """, (student_id, student_id))

        row = cursor.fetchone() or {}

        total_fees = money(row.get("total_fees"))
        amount_paid = money(row.get("amount_paid"))
        outstanding = max(total_fees - amount_paid, 0)

        if total_fees <= 0:
            status = "No Record"
        elif outstanding <= 0:
            status = "Paid"
        elif amount_paid > 0:
            status = "Partially Paid"
        else:
            status = "Outstanding"

        return {
            "total_fees": total_fees,
            "amount_paid": amount_paid,
            "outstanding": outstanding,
            "payment_status": status,
        }
    finally:
        cursor.close()
        connection.close()


@router.get("/invoices")
def get_fee_invoices(current_user: dict = Depends(get_current_user)):
    if current_user.get("role") != "student":
        raise HTTPException(status_code=403, detail="Student access required")

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT s.id AS student_id
            FROM students s
            WHERE s.user_id = %s
            LIMIT 1
        """, (current_user["user_id"],))

        student = cursor.fetchone()

        if not student:
            raise HTTPException(status_code=404, detail="Student record not found")

        cursor.execute("""
            SELECT
                i.id,
                i.invoice_number,
                i.description,
                i.academic_session,
                i.due_date,
                i.amount,
                i.status,
                COALESCE((
                    SELECT SUM(p.amount)
                    FROM fee_payments p
                    WHERE p.invoice_id = i.id
                      AND p.payment_status = 'successful'
                ), 0) AS paid_amount
            FROM fee_invoices i
            WHERE i.student_id = %s
              AND i.status <> 'cancelled'
            ORDER BY i.created_at DESC, i.id DESC
        """, (student["student_id"],))

        invoices = cursor.fetchall()

        for invoice in invoices:
            invoice["amount"] = money(invoice["amount"])
            invoice["paid_amount"] = money(invoice["paid_amount"])
            invoice["balance"] = max(
                invoice["amount"] - invoice["paid_amount"], 0
            )

            if invoice["due_date"]:
                invoice["due_date"] = invoice["due_date"].isoformat()

        return invoices
    finally:
        cursor.close()
        connection.close()


@router.get("/payments")
def get_fee_payments(current_user: dict = Depends(get_current_user)):
    if current_user.get("role") != "student":
        raise HTTPException(status_code=403, detail="Student access required")

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT s.id AS student_id
            FROM students s
            WHERE s.user_id = %s
            LIMIT 1
        """, (current_user["user_id"],))

        student = cursor.fetchone()

        if not student:
            raise HTTPException(status_code=404, detail="Student record not found")

        cursor.execute("""
            SELECT
                p.id,
                p.receipt_number,
                p.amount,
                p.payment_method,
                p.payment_status,
                p.transaction_reference,
                p.paid_at,
                i.invoice_number,
                i.description
            FROM fee_payments p
            JOIN fee_invoices i ON i.id = p.invoice_id
            WHERE p.student_id = %s
            ORDER BY p.paid_at DESC, p.id DESC
        """, (student["student_id"],))

        payments = cursor.fetchall()

        for payment in payments:
            payment["amount"] = money(payment["amount"])
            if payment["paid_at"]:
                payment["paid_at"] = payment["paid_at"].isoformat()

        return payments
    finally:
        cursor.close()
        connection.close()
