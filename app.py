from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.secret_key = "labtrack-local-secret"

# Replace this with your working MySQL password.
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": os.getenv("DB_PASSWORD"),
    "database": "lab_inventory"
}


def get_db():
    return mysql.connector.connect(**DB_CONFIG)


def fetch_all(sql, params=()):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(sql, params)
        return cursor.fetchall()
    finally:
        cursor.close()
        conn.close()


def execute(sql, params=()):
    conn = get_db()
    cursor = conn.cursor()
    try:
        cursor.execute(sql, params)
        conn.commit()
        return cursor.lastrowid
    finally:
        cursor.close()
        conn.close()


@app.route("/")
def dashboard():
    stats = {
        "equipment": fetch_all(
            "SELECT COUNT(*) n FROM EQUIPMENT"
        )[0]["n"],
        "labs": fetch_all(
            "SELECT COUNT(*) n FROM LABORATORY"
        )[0]["n"],
        "issued": fetch_all(
            "SELECT COUNT(*) n FROM ISSUE_RETURN WHERE status='Issued'"
        )[0]["n"],
        "maintenance": fetch_all(
            "SELECT COUNT(*) n FROM MAINTENANCE WHERE status='Pending'"
        )[0]["n"]
    }

    recent = fetch_all("""
        SELECT I.issue_id, S.name student_name,
               E.name equipment_name, I.issue_date,
               I.return_date, I.status
        FROM ISSUE_RETURN I
        JOIN STUDENT S ON S.student_id=I.student_id
        JOIN EQUIPMENT E ON E.equipment_id=I.equipment_id
        ORDER BY I.issue_id DESC LIMIT 5
    """)

    return render_template(
        "dashboard.html", stats=stats,
        recent=recent, page="dashboard"
    )


@app.route("/equipment")
def equipment():
    q = request.args.get("q", "").strip()
    lab_id = request.args.get("lab_id", "")

    search = "%" + q + "%"
    sql = """
        SELECT E.*, L.lab_name, S.name supplier_name
        FROM EQUIPMENT E
        JOIN LABORATORY L ON L.lab_id=E.lab_id
        LEFT JOIN SUPPLIER S ON S.supplier_id=E.supplier_id
        WHERE (E.name LIKE %s OR E.category LIKE %s
        OR E.brand LIKE %s OR E.serial_no LIKE %s)
    """
    params = [search, search, search, search]

    if lab_id:
        sql += " AND E.lab_id=%s"
        params.append(lab_id)

    sql += " ORDER BY E.equipment_id DESC"

    items = fetch_all(sql, tuple(params))
    labs = fetch_all(
        "SELECT * FROM LABORATORY ORDER BY lab_name"
    )
    suppliers = fetch_all(
        "SELECT * FROM SUPPLIER ORDER BY name"
    )

    return render_template(
        "equipment.html", equipment=items, labs=labs,
        suppliers=suppliers, q=q, selected_lab=lab_id,
        page="equipment"
    )


@app.route("/equipment/add", methods=["POST"])
def add_equipment():
    try:
        execute("""
            INSERT INTO EQUIPMENT
            (name, category, model, brand, serial_no,
             `condition`, purchase_date, lab_id, supplier_id)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            request.form["name"].strip(),
            request.form.get("category") or None,
            request.form.get("model") or None,
            request.form.get("brand") or None,
            request.form.get("serial_no") or None,
            request.form.get("condition") or "Good",
            request.form.get("purchase_date") or None,
            request.form["lab_id"],
            request.form.get("supplier_id") or None
        ))
        flash("Equipment added successfully.", "success")
    except Error as e:
        flash("Could not add equipment: " + str(e), "error")

    return redirect(url_for("equipment"))

@app.route("/equipment/edit/<int:item_id>", methods=["GET", "POST"])
def edit_equipment(item_id):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)

    try:
        if request.method == "POST":
            name = request.form.get("name", "").strip()
            category = request.form.get("category") or None
            model = request.form.get("model") or None
            brand = request.form.get("brand") or None
            serial_no = request.form.get("serial_no") or None
            condition = request.form.get("condition") or "Good"
            purchase_date = request.form.get("purchase_date") or None
            lab_id = request.form.get("lab_id")
            supplier_id = request.form.get("supplier_id") or None

            if not name or not lab_id:
                flash("Equipment name and laboratory are required.", "error")
                return redirect(url_for("edit_equipment", item_id=item_id))

            cursor.execute("""
                UPDATE EQUIPMENT
                SET name = %s,
                    category = %s,
                    model = %s,
                    brand = %s,
                    serial_no = %s,
                    `condition` = %s,
                    purchase_date = %s,
                    lab_id = %s,
                    supplier_id = %s
                WHERE equipment_id = %s
            """, (
                name, category, model, brand, serial_no,
                condition, purchase_date, lab_id,
                supplier_id, item_id
            ))

            conn.commit()
            flash("Equipment updated successfully!", "success")
            return redirect(url_for("equipment"))

        cursor.execute(
            "SELECT * FROM EQUIPMENT WHERE equipment_id = %s",
            (item_id,)
        )
        item = cursor.fetchone()

        if not item:
            flash("Equipment record not found.", "error")
            return redirect(url_for("equipment"))

        cursor.execute("SELECT * FROM LABORATORY")
        laboratories = cursor.fetchall()

        cursor.execute("SELECT * FROM SUPPLIER")
        suppliers = cursor.fetchall()

        return render_template(
            "edit_equipment.html",
            item=item,
            laboratories=laboratories,
            suppliers=suppliers
        )

    except mysql.connector.Error as e:
        conn.rollback()
        flash(f"Database error: {e}", "error")
        return redirect(url_for("equipment"))

    finally:
        cursor.close()
        conn.close()



@app.route("/equipment/<int:item_id>/delete", methods=["POST"])
def delete_equipment(item_id):
    try:
        execute(
            "DELETE FROM EQUIPMENT WHERE equipment_id=%s",
            (item_id,)
        )
        flash("Equipment deleted.", "success")
    except Error as e:
        flash("Cannot delete this record: " + str(e), "error")

    return redirect(url_for("equipment"))


@app.route("/issues")
def issues():
    students = fetch_all("SELECT * FROM STUDENT ORDER BY name")
    faculty = fetch_all("SELECT * FROM FACULTY ORDER BY name")

    available = fetch_all("""
        SELECT E.equipment_id, E.name, E.serial_no
        FROM EQUIPMENT E
        WHERE E.equipment_id NOT IN (
            SELECT equipment_id FROM ISSUE_RETURN
            WHERE status='Issued'
        )
        ORDER BY E.name
    """)

    records = fetch_all("""
        SELECT I.*, S.name student_name, E.name equipment_name,
               F.name faculty_name
        FROM ISSUE_RETURN I
        JOIN STUDENT S ON S.student_id=I.student_id
        JOIN EQUIPMENT E ON E.equipment_id=I.equipment_id
        JOIN FACULTY F ON F.faculty_id=I.approving_faculty_id
        ORDER BY I.issue_id DESC
    """)

    return render_template(
        "issues.html", issues=records, students=students,
        faculty=faculty, available=available, page="issues"
    )



@app.route("/issues/issue", methods=["POST"])
def issue_equipment():
    try:
        student_id = request.form.get("student_id")
        equipment_id = request.form.get("equipment_id")
        faculty_id = request.form.get("faculty_id")
        issue_date = request.form.get("issue_date")
        remarks = request.form.get("remarks") or None

        if not all([student_id, equipment_id, faculty_id, issue_date]):
            flash("Please fill in all required issue details.", "error")
            return redirect(url_for("issues"))

        # Check that the equipment exists and inspect its condition.
        equipment = fetch_all("""
            SELECT equipment_id, `condition`
            FROM EQUIPMENT
            WHERE equipment_id = %s
        """, (equipment_id,))

        if not equipment:
            flash("Equipment not found.", "error")
            return redirect(url_for("issues"))

        condition = (equipment[0]["condition"] or "").strip().lower()

        if condition in ("damaged", "needs repair", "under maintenance"):
            flash("This equipment cannot be issued because it needs repair.", "error")
            return redirect(url_for("issues"))

        # Check whether this equipment already has an active issue.
        active_issue = fetch_all("""
            SELECT issue_id
            FROM ISSUE_RETURN
            WHERE equipment_id = %s
              AND status = 'Issued'
        """, (equipment_id,))

        if active_issue:
            flash("This equipment is already issued.", "error")
            return redirect(url_for("issues"))

        execute("""
            INSERT INTO ISSUE_RETURN
                (student_id, equipment_id, approving_faculty_id,
                 issue_date, status, remarks)
            VALUES (%s, %s, %s, %s, 'Issued', %s)
        """, (
            student_id,
            equipment_id,
            faculty_id,
            issue_date,
            remarks
        ))

        flash("Issue recorded successfully.", "success")

    except Exception as e:
        flash("Could not issue equipment: " + str(e), "error")

    return redirect(url_for("issues"))



@app.route("/issues/<int:issue_id>/return", methods=["POST"])
def return_equipment(issue_id):
    try:
        execute("""
            UPDATE ISSUE_RETURN
            SET status='Returned', return_date=%s
            WHERE issue_id=%s AND status='Issued'
        """, (request.form["return_date"], issue_id))
        flash("Return recorded.", "success")
    except Error as e:
        flash("Could not record return: " + str(e), "error")

    return redirect(url_for("issues"))


@app.route("/maintenance")
def maintenance():
    records = fetch_all("""
        SELECT M.*, E.name equipment_name
        FROM MAINTENANCE M
        JOIN EQUIPMENT E ON E.equipment_id=M.equipment_id
        ORDER BY M.maintenance_id DESC
    """)
    items = fetch_all("SELECT * FROM EQUIPMENT ORDER BY name")

    return render_template(
        "maintenance.html", maintenance=records,
        equipment=items, page="maintenance"
    )


@app.route("/maintenance/add", methods=["POST"])
def add_maintenance():
    try:
        execute("""
            INSERT INTO MAINTENANCE
            (equipment_id, `date`, type, description, cost, status)
            VALUES (%s,%s,%s,%s,%s,%s)
        """, (
            request.form["equipment_id"],
            request.form["date"],
            request.form["type"],
            request.form.get("description") or None,
            request.form.get("cost") or 0,
            request.form.get("status") or "Pending"
        ))
        flash("Maintenance record added.", "success")
    except Error as e:
        flash("Could not add maintenance: " + str(e), "error")

    return redirect(url_for("maintenance"))


@app.route("/maintenance/<int:maintenance_id>/status",
           methods=["POST"])
def update_maintenance(maintenance_id):
    try:
        execute("""
            UPDATE MAINTENANCE SET status=%s
            WHERE maintenance_id=%s
        """, (request.form["status"], maintenance_id))
        flash("Maintenance status updated.", "success")
    except Error as e:
        flash("Could not update status: " + str(e), "error")

    return redirect(url_for("maintenance"))


@app.route("/people")
def people():
    students = fetch_all("SELECT * FROM STUDENT ORDER BY name")
    faculty = fetch_all("SELECT * FROM FACULTY ORDER BY name")
    labs = fetch_all("SELECT * FROM LABORATORY ORDER BY lab_name")
    suppliers = fetch_all("SELECT * FROM SUPPLIER ORDER BY name")

    return render_template(
        "people.html", students=students, faculty=faculty,
        labs=labs, suppliers=suppliers, page="people"
    )


@app.errorhandler(500)
def server_error(error):
    app.logger.exception("Server error")
    return render_template("error.html"), 500


if __name__ == "__main__":
    app.run(debug=True)
