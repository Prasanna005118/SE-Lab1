<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Hospital Appointment Management System</title>
</head>
<body>
    <h2>🏥 Hospital Appointment Management System</h2>
    <form action="confirmation.jsp" method="post">
        <label for="patientName">Patient Name 🧍:</label>
        <input type="text" id="patientName" name="patientName" required><br><br>

        <label for="department">Department 🏥:</label>
        <select id="department" name="department" required>
            <option value="">-- Select Department --</option>
            <option value="Cardiology">Cardiology</option>
            <option value="Orthopedics">Orthopedics</option>
            <option value="Dermatology">Dermatology</option>
            <option value="General Medicine">General Medicine</option>
        </select><br><br>

        <label for="doctorName">Doctor 👨‍⚕️:</label>
        <select id="doctorName" name="doctorName" required>
            <option value="">-- Select Doctor --</option>
            <option value="Dr. Smith">Dr. Smith</option>
            <option value="Dr. Brown">Dr. Brown</option>
            <option value="Dr. Lee">Dr. Lee</option>
            <option value="Dr. Patel">Dr. Patel</option>
        </select><br><br>

        <label for="appointmentDate">Appointment Date 📅:</label>
        <input type="date" id="appointmentDate" name="appointmentDate" required><br><br>

        <label for="symptoms">Symptoms 🩺:</label><br>
        <textarea id="symptoms" name="symptoms" rows="4" cols="40" required></textarea><br><br>

        <input type="submit" value="Book Appointment">
    </form>
</body>
</html>

