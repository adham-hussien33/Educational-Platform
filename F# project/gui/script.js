// API Configuration
let apiUrl = 'http://localhost:5039';
let currentUsername = '';
let currentRole = '';
let authHeaders = {};

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    checkConnection();
    setupEventListeners();
});

// Setup event listeners
function setupEventListeners() {
    document.getElementById('loginBtn').addEventListener('click', handleLogin);
    document.getElementById('logoutBtn').addEventListener('click', handleLogout);
    document.getElementById('addStudentBtn').addEventListener('click', addStudent);
    document.getElementById('refreshStudentsBtn').addEventListener('click', loadStudents);
    document.getElementById('addGradeBtn').addEventListener('click', addGrade);
    document.getElementById('viewGradesBtn').addEventListener('click', viewStudentGrades);
    document.getElementById('refreshStatsBtn').addEventListener('click', loadStatistics);
    document.getElementById('saveStudentBtn').addEventListener('click', saveStudent);
    document.getElementById('cancelEditBtn').addEventListener('click', cancelEdit);
    
    // Enter key support
    document.getElementById('password').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') handleLogin();
    });
}

// Check API connection
async function checkConnection() {
    const statusIndicator = document.getElementById('statusIndicator');
    const statusText = document.getElementById('statusText');
    
    try {
        const response = await fetch(`${apiUrl}/api/students`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });
        
        if (response.ok || response.status === 401) {
            statusIndicator.classList.add('connected');
            statusText.textContent = 'Connected';
        } else {
            throw new Error('Connection failed');
        }
    } catch (error) {
        statusIndicator.classList.remove('connected');
        statusText.textContent = 'Disconnected';
    }
}

// Login
async function handleLogin() {
    apiUrl = document.getElementById('apiUrl').value.trim() || 'http://localhost:5039';
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value.trim();
    const loginMessage = document.getElementById('loginMessage');
    
    if (!username || !password) {
        showMessage(loginMessage, 'Please enter username and password', 'error');
        return;
    }
    
    try {
        const response = await fetch(`${apiUrl}/api/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            currentUsername = username.toLowerCase();
            currentRole = data.role;
            authHeaders = {
                'Content-Type': 'application/json',
                'X-Username': username.toLowerCase()
            };
            
            document.getElementById('currentUser').textContent = username;
            document.getElementById('currentRole').textContent = currentRole;
            document.getElementById('loginCard').style.display = 'none';
            document.getElementById('mainContent').style.display = 'block';
            
            // Show/hide sections based on role
            updateUIForRole(currentRole);
            
            showMessage(loginMessage, 'Login successful!', 'success');
            await checkConnection();
            
            // Only load students list for Admin
            if (currentRole === 'Admin') {
                await loadStudents();
            }
            // Statistics are available to all roles
            await loadStatistics();
        } else {
            showMessage(loginMessage, data.message || 'Login failed', 'error');
        }
    } catch (error) {
        showMessage(loginMessage, `Connection error: ${error.message}`, 'error');
        checkConnection();
    }
}

// Update UI based on role
function updateUIForRole(role) {
    const studentsSection = document.getElementById('studentsManagementSection');
    const gradesSection = document.getElementById('gradesManagementSection');
    const studentNote = document.getElementById('studentNote');
    const viewGradesTitle = document.getElementById('viewGradesTitle');
    const adminViewGradesSection = document.getElementById('adminViewGradesSection');
    
    if (role === 'Student') {
        // Hide sections for Student
        if (studentsSection) studentsSection.style.display = 'none';
        if (gradesSection) gradesSection.style.display = 'none';
        if (studentNote) studentNote.style.display = 'block';
        if (adminViewGradesSection) adminViewGradesSection.style.display = 'none';
        if (viewGradesTitle) viewGradesTitle.textContent = 'My Grades';
        // Automatically load student's grades
        loadMyGrades();
    } else {
        // Show all sections for Admin
        if (studentsSection) studentsSection.style.display = 'block';
        if (gradesSection) gradesSection.style.display = 'block';
        if (studentNote) studentNote.style.display = 'none';
        if (adminViewGradesSection) adminViewGradesSection.style.display = 'block';
        if (viewGradesTitle) viewGradesTitle.textContent = 'View Student Grades';
    }
}

// Logout
function handleLogout() {
    currentUsername = '';
    currentRole = '';
    authHeaders = {};
    document.getElementById('loginCard').style.display = 'block';
    document.getElementById('mainContent').style.display = 'none';
    document.getElementById('username').value = '';
    document.getElementById('password').value = '';
}

// Add Student
async function addStudent() {
    const name = document.getElementById('studentName').value.trim();
    const studentId = document.getElementById('studentId').value.trim();
    const email = document.getElementById('studentEmail').value.trim();
    const password = document.getElementById('studentPassword').value.trim();
    const messageEl = document.getElementById('studentMessage');
    
    if (!name || !studentId || !email || !password) {
        showMessage(messageEl, 'Please fill all fields including password', 'error');
        return;
    }
    
    if (password.length < 3) {
        showMessage(messageEl, 'Password must be at least 3 characters long', 'error');
        return;
    }
    
    try {
        const response = await fetch(`${apiUrl}/api/students`, {
            method: 'POST',
            headers: authHeaders,
            body: JSON.stringify({ name, studentId, email, password })
        });
        
        const data = await response.json();
        
        if (response.ok || response.status === 201) {
            // Sanitize username to match backend logic
            const username = name.toLowerCase()
                .replace(/\s/g, '') // Remove spaces
                .replace(/-/g, '') // Remove hyphens
                .replace(/_/g, '') // Remove underscores
                .replace(/\./g, '') // Remove periods
                .replace(/,/g, '') // Remove commas
                .replace(/'/g, '') // Remove apostrophes
                .replace(/[^a-z0-9]/g, ''); // Remove any other non-alphanumeric characters
            showMessage(messageEl, `Student added successfully! Username: ${username}`, 'success');
            document.getElementById('studentName').value = '';
            document.getElementById('studentId').value = '';
            document.getElementById('studentEmail').value = '';
            document.getElementById('studentPassword').value = '';
            await loadStudents();
        } else {
            showMessage(messageEl, data.message || 'Failed to add student', 'error');
        }
    } catch (error) {
        showMessage(messageEl, `Error: ${error.message}`, 'error');
    }
}

// Load My Grades (Student only)
async function loadMyGrades() {
    if (currentRole !== 'Student') {
        return;
    }
    
    const display = document.getElementById('studentGradesDisplay');
    display.innerHTML = '<div class="loading"></div> Loading your grades...';
    
    try {
        const response = await fetch(`${apiUrl}/api/students/my-grades`, {
            method: 'GET',
            headers: authHeaders
        });
        
        if (response.ok) {
            let data;
            try {
                data = await response.json();
            } catch (e) {
                const text = await response.text();
                display.innerHTML = `<p style="padding: 20px; color: #ef4444;">Error parsing response: ${text}</p>`;
                return;
            }
            
            let html = `
                <div class="student-summary">
                    <h4>${data.student.name}</h4>
                    <p><strong>Student ID:</strong> ${data.student.studentId}</p>
                    <p><strong>Email:</strong> ${data.student.email}</p>
                    ${data.average ? `<p><strong>Average:</strong> ${data.average.toFixed(2)}%</p>` : ''}
                    <p><strong>Total Score:</strong> ${data.total.totalScore.toFixed(2)} / ${data.total.totalMaxScore.toFixed(2)}</p>
                </div>
            `;
            
            if (data.grades && data.grades.length > 0) {
                html += '<h4>Your Grades:</h4>';
                html += data.grades.map(grade => `
                    <div class="grade-item">
                        <strong>${grade.subject}</strong><br>
                        Score: ${grade.score} / ${grade.maxScore} (${grade.percentage.toFixed(2)}%)<br>
                        <small style="color: #6b7280;">Recorded: ${new Date(grade.dateRecorded).toLocaleDateString()}</small>
                    </div>
                `).join('');
            } else {
                html += '<p style="padding: 20px; text-align: center; color: #6b7280;">No grades found yet. Your grades will appear here once they are added.</p>';
            }
            
            display.innerHTML = html;
        } else {
            let errorMessage = 'Failed to load your grades';
            try {
                const errorData = await response.json();
                errorMessage = errorData.message || errorData.title || errorMessage;
            } catch (e) {
                const text = await response.text();
                if (text) errorMessage = text;
            }
            display.innerHTML = `<p style="padding: 20px; color: #ef4444;">${errorMessage}</p>`;
        }
    } catch (error) {
        display.innerHTML = `<p style="padding: 20px; color: #ef4444;">Error: ${error.message}</p>`;
    }
}

// Load Students (Admin only)
async function loadStudents() {
    // Don't load students list for Students
    if (currentRole === 'Student') {
        return;
    }
    
    const studentsList = document.getElementById('studentsList');
    if (!studentsList) return;
    
    studentsList.innerHTML = '<div class="loading"></div> Loading...';
    
    try {
        const response = await fetch(`${apiUrl}/api/students`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });
        
        if (response.ok) {
            const students = await response.json();
            
            if (students.length === 0) {
                studentsList.innerHTML = '<p style="padding: 20px; text-align: center; color: #6b7280;">No students found</p>';
                return;
            }
            
            studentsList.innerHTML = students.map(student => {
                // Generate username from student name (same logic as backend)
                const username = student.name.toLowerCase()
                    .replace(/\s/g, '')
                    .replace(/-/g, '')
                    .replace(/_/g, '')
                    .replace(/\./g, '')
                    .replace(/,/g, '')
                    .replace(/'/g, '')
                    .replace(/[^a-z0-9]/g, '');
                
                return `
                <div class="student-item">
                    <div class="student-info">
                        <strong>${student.name}</strong><br>
                        <small>ID: ${student.studentId} | Email: ${student.email}</small><br>
                        <small style="color: #6b7280;">Username: ${username}</small>
                    </div>
                    <div class="student-actions">
                        <button class="btn btn-primary" onclick="viewStudentGradesByUsername('${username}')">View Grades</button>
                        ${currentRole === 'Admin' ? `
                            <button class="btn btn-secondary" onclick="editStudent(${student.id}, '${student.name}', '${student.studentId}', '${student.email}')">Edit</button>
                            <button class="btn btn-danger" onclick="deleteStudent(${student.id})">Delete</button>
                        ` : ''}
                    </div>
                </div>
            `;
            }).join('');
        } else {
            studentsList.innerHTML = '<p style="padding: 20px; color: #ef4444;">Failed to load students</p>';
        }
    } catch (error) {
        studentsList.innerHTML = `<p style="padding: 20px; color: #ef4444;">Error: ${error.message}</p>`;
    }
}

// Delete Student
async function deleteStudent(id) {
    if (!confirm('Are you sure you want to delete this student?')) return;
    
    try {
        const response = await fetch(`${apiUrl}/api/students/${id}`, {
            method: 'DELETE',
            headers: authHeaders
        });
        
        if (response.ok || response.status === 204) {
            await loadStudents();
            showMessage(document.getElementById('studentMessage'), 'Student deleted successfully', 'success');
        } else {
            const data = await response.json();
            showMessage(document.getElementById('studentMessage'), data.message || 'Failed to delete student', 'error');
        }
    } catch (error) {
        showMessage(document.getElementById('studentMessage'), `Error: ${error.message}`, 'error');
    }
}

// Add Grade
async function addGrade() {
    const studentId = document.getElementById('gradeStudentId').value.trim();
    const subject = document.getElementById('gradeSubject').value.trim();
    const score = parseFloat(document.getElementById('gradeScore').value);
    const maxScore = parseFloat(document.getElementById('gradeMaxScore').value);
    const messageEl = document.getElementById('gradeMessage');
    
    if (!studentId || !subject || isNaN(score) || isNaN(maxScore)) {
        showMessage(messageEl, 'Please fill all fields with valid values', 'error');
        return;
    }
    
    try {
        const response = await fetch(`${apiUrl}/api/grades`, {
            method: 'POST',
            headers: authHeaders,
            body: JSON.stringify({ studentId, subject, score, maxScore })
        });
        
        const data = await response.json();
        
        if (response.ok || response.status === 201) {
            showMessage(messageEl, 'Grade added successfully!', 'success');
            document.getElementById('gradeStudentId').value = '';
            document.getElementById('gradeSubject').value = '';
            document.getElementById('gradeScore').value = '';
            document.getElementById('gradeMaxScore').value = '';
        } else {
            showMessage(messageEl, data.message || 'Failed to add grade', 'error');
        }
    } catch (error) {
        showMessage(messageEl, `Error: ${error.message}`, 'error');
    }
}

// View Student Grades by Username (Admin)
async function viewStudentGrades() {
    const username = document.getElementById('viewStudentUsername').value.trim();
    if (!username) {
        showMessage(document.getElementById('studentMessage'), 'Please enter a username', 'error');
        return;
    }
    await viewStudentGradesByUsername(username);
}

// View Student Grades by Username
async function viewStudentGradesByUsername(username) {
    const display = document.getElementById('studentGradesDisplay');
    display.innerHTML = '<div class="loading"></div> Loading...';
    
    try {
        const response = await fetch(`${apiUrl}/api/students/by-username/${encodeURIComponent(username)}/grades`, {
            method: 'GET',
            headers: authHeaders
        });
        
        if (response.ok) {
            const data = await response.json();
            
            let html = `
                <div class="student-summary">
                    <h4>${data.student.name}</h4>
                    <p><strong>Student ID:</strong> ${data.student.studentId}</p>
                    <p><strong>Email:</strong> ${data.student.email}</p>
                    <p><strong>Username:</strong> ${username}</p>
                    ${data.average ? `<p><strong>Average:</strong> ${data.average.toFixed(2)}%</p>` : ''}
                    <p><strong>Total Score:</strong> ${data.total.totalScore.toFixed(2)} / ${data.total.totalMaxScore.toFixed(2)}</p>
                </div>
            `;
            
            if (data.grades && data.grades.length > 0) {
                html += '<h4>Grades:</h4>';
                html += data.grades.map(grade => `
                    <div class="grade-item">
                        <strong>${grade.subject}</strong><br>
                        Score: ${grade.score} / ${grade.maxScore} (${grade.percentage.toFixed(2)}%)<br>
                        <small style="color: #6b7280;">Recorded: ${new Date(grade.dateRecorded).toLocaleDateString()}</small>
                    </div>
                `).join('');
            } else {
                html += '<p style="padding: 20px; text-align: center; color: #6b7280;">No grades found for this student</p>';
            }
            
            display.innerHTML = html;
            document.getElementById('viewStudentUsername').value = username;
        } else {
            let errorMessage = 'Student not found or has no grades';
            try {
                const errorData = await response.json();
                errorMessage = errorData.message || errorData.title || errorMessage;
            } catch (e) {
                const text = await response.text();
                if (text) errorMessage = text;
            }
            display.innerHTML = `<p style="padding: 20px; color: #ef4444;">${errorMessage}</p>`;
        }
    } catch (error) {
        display.innerHTML = `<p style="padding: 20px; color: #ef4444;">Error: ${error.message}</p>`;
    }
}

// View Student Grades by ID
async function viewStudentGradesById(studentId) {
    const display = document.getElementById('studentGradesDisplay');
    display.innerHTML = '<div class="loading"></div> Loading...';
    
    try {
        const response = await fetch(`${apiUrl}/api/students/${studentId}/grades`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });
        
        if (response.ok) {
            const data = await response.json();
            
            let html = `
                <div class="student-summary">
                    <h4>${data.student.name}</h4>
                    <p><strong>Student ID:</strong> ${data.student.studentId}</p>
                    <p><strong>Email:</strong> ${data.student.email}</p>
                    ${data.average ? `<p><strong>Average:</strong> ${data.average.toFixed(2)}%</p>` : ''}
                    <p><strong>Total Score:</strong> ${data.total.totalScore.toFixed(2)} / ${data.total.totalMaxScore.toFixed(2)}</p>
                </div>
            `;
            
            if (data.grades && data.grades.length > 0) {
                html += '<h4>Grades:</h4>';
                html += data.grades.map(grade => `
                    <div class="grade-item">
                        <strong>${grade.subject}</strong><br>
                        Score: ${grade.score} / ${grade.maxScore} (${grade.percentage.toFixed(2)}%)<br>
                        <small style="color: #6b7280;">Recorded: ${new Date(grade.dateRecorded).toLocaleDateString()}</small>
                    </div>
                `).join('');
            } else {
                html += '<p style="padding: 20px; text-align: center; color: #6b7280;">No grades found for this student</p>';
            }
            
            display.innerHTML = html;
            document.getElementById('viewStudentId').value = studentId;
        } else {
            display.innerHTML = '<p style="padding: 20px; color: #ef4444;">Student not found or has no grades</p>';
        }
    } catch (error) {
        display.innerHTML = `<p style="padding: 20px; color: #ef4444;">Error: ${error.message}</p>`;
    }
}

// Load Statistics
async function loadStatistics() {
    const display = document.getElementById('statisticsDisplay');
    display.innerHTML = '<div class="loading"></div> Loading...';
    
    try {
        // Get subject filter if provided
        const subjectInput = document.getElementById('statisticsSubject');
        const subject = subjectInput ? subjectInput.value.trim() : '';
        
        // Build URL with optional subject parameter
        let url = `${apiUrl}/api/statistics`;
        if (subject) {
            url += `?subject=${encodeURIComponent(subject)}`;
        }
        
        const response = await fetch(url, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });
        
        if (response.ok) {
            const stats = await response.json();
            
            // Show subject filter info if filtering
            let subjectInfo = '';
            if (subject) {
                subjectInfo = `<div style="padding: 10px; margin-bottom: 15px; background-color: #e0e7ff; border-left: 4px solid #6366f1; border-radius: 4px;">
                    <strong>Filtered by Subject:</strong> ${subject}
                </div>`;
            }
            
            let html = subjectInfo + `
                <div class="stat-item">
                    <h4>Total Students${subject ? ' (with grades in this subject)' : ''}</h4>
                    <div class="stat-value">${stats.totalStudents}</div>
                </div>
                <div class="stat-item">
                    <h4>Total Grades${subject ? ' (in this subject)' : ''}</h4>
                    <div class="stat-value">${stats.totalGrades}</div>
                </div>
            `;
            
            if (stats.highestAverage) {
                const label = subject ? 'Highest Grade' : 'Highest Average';
                html += `
                    <div class="stat-item">
                        <h4>${label}${subject ? ` (${subject})` : ''}</h4>
                        <div class="stat-value">${stats.highestAverage.average.toFixed(2)}%</div>
                        <div class="stat-label">${stats.highestAverage.student.name} (${stats.highestAverage.student.studentId})</div>
                    </div>
                `;
            }
            
            if (stats.lowestAverage) {
                const label = subject ? 'Lowest Grade' : 'Lowest Average';
                html += `
                    <div class="stat-item">
                        <h4>${label}${subject ? ` (${subject})` : ''}</h4>
                        <div class="stat-value">${stats.lowestAverage.average.toFixed(2)}%</div>
                        <div class="stat-label">${stats.lowestAverage.student.name} (${stats.lowestAverage.student.studentId})</div>
                    </div>
                `;
            }
            
            if (stats.passRate !== null && stats.passRate !== undefined) {
                html += `
                    <div class="stat-item">
                        <h4>Pass Rate${subject ? ` (${subject})` : ''}</h4>
                        <div class="stat-value">${stats.passRate.toFixed(2)}%</div>
                    </div>
                `;
            }
            
            if (!stats.highestAverage && !stats.lowestAverage) {
                html += `<p style="padding: 20px; text-align: center; color: #6b7280;">
                    ${subject ? `No grades found for subject "${subject}"` : 'No statistics available'}
                </p>`;
            }
            
            display.innerHTML = html;
        } else {
            let errorMessage = 'Failed to load statistics';
            // Try to get error message from response
            try {
                // First try to read as text (for BadRequest with string)
                const text = await response.text();
                if (text && text.trim().length > 0) {
                    // Try to parse as JSON, if it fails, use as plain text
                    try {
                        const errorData = JSON.parse(text);
                        errorMessage = errorData.message || errorData.title || text;
                    } catch {
                        errorMessage = text;
                    }
                } else {
                    errorMessage = response.statusText || errorMessage;
                }
            } catch (e) {
                errorMessage = response.statusText || `Error ${response.status}: ${response.statusText}`;
            }
            display.innerHTML = `<p style="padding: 20px; color: #ef4444;">${errorMessage}</p>`;
        }
    } catch (error) {
        display.innerHTML = `<p style="padding: 20px; color: #ef4444;">Error: ${error.message}</p>`;
    }
}

// Helper function to show messages
function showMessage(element, message, type) {
    element.textContent = message;
    element.className = `message ${type}`;
    setTimeout(() => {
        element.className = 'message';
        element.textContent = '';
    }, 5000);
}

// Edit Student
function editStudent(id, name, studentId, email) {
    document.getElementById('editStudentDbId').value = id;
    document.getElementById('editStudentName').value = name;
    document.getElementById('editStudentId').value = studentId;
    document.getElementById('editStudentEmail').value = email;
    document.getElementById('editStudentPassword').value = '';
    document.getElementById('editStudentSection').style.display = 'block';
    document.getElementById('editStudentSection').scrollIntoView({ behavior: 'smooth' });
}

function cancelEdit() {
    document.getElementById('editStudentSection').style.display = 'none';
    document.getElementById('editStudentDbId').value = '';
    document.getElementById('editStudentName').value = '';
    document.getElementById('editStudentId').value = '';
    document.getElementById('editStudentEmail').value = '';
    document.getElementById('editStudentPassword').value = '';
}

async function saveStudent() {
    const id = parseInt(document.getElementById('editStudentDbId').value);
    const name = document.getElementById('editStudentName').value.trim();
    const studentId = document.getElementById('editStudentId').value.trim();
    const email = document.getElementById('editStudentEmail').value.trim();
    const password = document.getElementById('editStudentPassword').value.trim();
    const messageEl = document.getElementById('studentMessage');
    
    if (!name || !studentId || !email) {
        showMessage(messageEl, 'Please fill all required fields', 'error');
        return;
    }
    
    try {
        const updateDto = {
            name,
            studentId,
            email,
            password: password.length > 0 ? password : null
        };
        
        const response = await fetch(`${apiUrl}/api/students/${id}`, {
            method: 'PUT',
            headers: authHeaders,
            body: JSON.stringify(updateDto)
        });
        
        if (response.ok) {
            let data;
            try {
                data = await response.json();
            } catch (e) {
                // If response is not JSON, that's okay - just show success
                showMessage(messageEl, 'Student updated successfully!', 'success');
                cancelEdit();
                await loadStudents();
                return;
            }
            showMessage(messageEl, 'Student updated successfully!', 'success');
            cancelEdit();
            await loadStudents();
        } else {
            // Handle error response - check content type first
            let errorMessage = 'Failed to update student';
            const contentType = response.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                try {
                    const errorData = await response.json();
                    errorMessage = errorData.message || errorData.title || errorMessage;
                } catch (e) {
                    errorMessage = response.statusText || errorMessage;
                }
            } else {
                try {
                    const text = await response.text();
                    if (text) errorMessage = text;
                    else errorMessage = response.statusText || errorMessage;
                } catch (e) {
                    errorMessage = response.statusText || errorMessage;
                }
            }
            showMessage(messageEl, errorMessage, 'error');
        }
    } catch (error) {
        showMessage(messageEl, `Error: ${error.message}`, 'error');
    }
}

// Make functions globally available
window.viewStudentGradesById = viewStudentGradesById;
window.viewStudentGradesByUsername = viewStudentGradesByUsername;
window.deleteStudent = deleteStudent;
window.editStudent = editStudent;
