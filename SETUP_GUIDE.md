# Airline Management System

A full-stack airline management application built with **Java Spring Boot**, **MySQL**, and **Angular 18**. This system allows admins to manage flights and passengers to book flights with a modern, responsive UI.

![Tech Stack](https://img.shields.io/badge/Java-17-orange) ![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.1-brightgreen) ![Angular](https://img.shields.io/badge/Angular-18-red) ![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Project Structure](#project-structure)
- [Test Credentials](#test-credentials)
- [Troubleshooting](#troubleshooting)

---

## ✨ Features

### Admin Features
- ✅ View all flights in a responsive grid
- ✅ Add new flights with complete details
- ✅ Edit/Update flight information (time, seats, price, status)
- ✅ Delete flights with confirmation
- ✅ View passenger manifest for each flight
- ✅ Real-time seat availability tracking

### Passenger Features
- ✅ Browse available flights
- ✅ Book flights with multiple passengers
- ✅ Enter passenger details (name, age, gender, email, phone)
- ✅ Mock payment gateway for testing
- ✅ View booking history with references
- ✅ Track payment status

### General Features
- 🔐 JWT-based authentication
- 👥 Role-based access control (Admin/Passenger)
- 🎨 Modern, minimal UI with smooth animations
- 📱 Responsive design
- 💾 MySQL database persistence
- 🔄 Automatic seat assignment

---

## 🛠️ Tech Stack

### Backend
- **Java 17**
- **Spring Boot 3.2.1**
- **Spring Security** (JWT Authentication)
- **Spring Data JPA** (Hibernate)
- **MySQL 8.0** (MariaDB compatible)
- **Maven** (Build tool)
- **Lombok** (Boilerplate reduction)

### Frontend
- **Angular 18**
- **TypeScript**
- **RxJS**
- **Angular Router**
- **HTTP Client**
- **Custom CSS** (Modern gradient design)

---

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

1. **Java Development Kit (JDK) 17 or higher**
   ```bash
   java -version
   ```

2. **Maven 3.6+**
   ```bash
   mvn -version
   ```

3. **Node.js 20.x or higher**
   ```bash
   node -v
   ```

4. **npm 10.x or higher**
   ```bash
   npm -v
   ```

5. **MySQL 8.0 or MariaDB 10.11+**
   ```bash
   mysql --version
   ```

6. **Angular CLI 18**
   ```bash
   npm install -g @angular/cli@18
   ng version
   ```

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd airline-management-system
```

### 2. Database Setup

#### Start MySQL/MariaDB Server

**On Linux:**
```bash
sudo service mysql start
# OR
sudo service mariadb start
```

**On macOS:**
```bash
brew services start mysql
# OR
brew services start mariadb
```

**On Windows:**
```bash
net start MySQL
```

#### Create Database and User

```bash
mysql -u root -p
```

Then execute:

```sql
CREATE DATABASE airline_management;

CREATE USER 'airlineuser'@'localhost' IDENTIFIED BY 'airline@2026';

GRANT ALL PRIVILEGES ON airline_management.* TO 'airlineuser'@'localhost';

FLUSH PRIVILEGES;

EXIT;
```

### 3. Backend Setup

Navigate to the backend directory:

```bash
cd backend-java
```

#### Update Database Configuration (if needed)

Edit `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/airline_management?serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true
spring.datasource.username=airlineuser
spring.datasource.password=airline@2026
```

#### Build the Project

```bash
mvn clean install -DskipTests
```

This will:
- Download all dependencies
- Compile the code
- Create an executable JAR in `target/` directory

### 4. Frontend Setup

Navigate to the frontend directory:

```bash
cd ../frontend-angular
```

#### Install Dependencies

```bash
npm install
```

---

## 🎯 Running the Application

### Step 1: Start the Backend Server

From the `backend-java` directory:

```bash
java -jar target/airline-management-1.0.0.jar
```

**Or using Maven:**

```bash
mvn spring-boot:run
```

The backend will start on **http://localhost:8081**

You should see:
```
Started AirlineManagementApplication in X.XXX seconds
```

### Step 2: Start the Frontend Server

From the `frontend-angular` directory:

```bash
ng serve
```

**Or to allow external access:**

```bash
ng serve --host 0.0.0.0 --port 4200
```

The frontend will be available at **http://localhost:4200**

You should see:
```
✔ Building...
Application bundle generation complete.
  ➜  Local:   http://localhost:4200/
```

### Step 3: Access the Application

Open your browser and navigate to:
```
http://localhost:4200
```

---

## 🔑 Test Credentials

### Admin Account
- **Email:** `admin@airline.com`
- **Password:** `admin123`

### Passenger Account
- **Email:** `test@test.com`
- **Password:** `test123`

### Create New Account
You can also register a new account from the login page.

---

## 📚 API Documentation

### Base URL
```
http://localhost:8081/api
```

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe",
  "role": "PASSENGER",
  "phoneNumber": "1234567890"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "PASSENGER"
}
```

### Flight Endpoints

#### Get All Flights (Public)
```http
GET /api/flights/all
```

#### Get All Flights (Authenticated)
```http
GET /api/flights
Authorization: Bearer <token>
```

#### Create Flight (Admin Only)
```http
POST /api/admin/flights
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "flightNumber": "AA101",
  "origin": "New York",
  "destination": "Los Angeles",
  "departureTime": "2026-04-01T08:00:00",
  "arrivalTime": "2026-04-01T11:30:00",
  "totalSeats": 180,
  "availableSeats": 180,
  "price": 299.99,
  "status": "ACTIVE"
}
```

#### Update Flight (Admin Only)
```http
PUT /api/admin/flights/{id}
Authorization: Bearer <admin-token>
Content-Type: application/json
```

#### Delete Flight (Admin Only)
```http
DELETE /api/admin/flights/{id}
Authorization: Bearer <admin-token>
```

#### Get Flight Passengers (Admin Only)
```http
GET /api/admin/flights/{flightId}/passengers
Authorization: Bearer <admin-token>
```

### Booking Endpoints

#### Create Booking (Passenger)
```http
POST /api/bookings
Authorization: Bearer <passenger-token>
Content-Type: application/json

{
  "flightId": 1,
  "passengers": [
    {
      "name": "John Doe",
      "age": 30,
      "gender": "Male",
      "email": "john@example.com",
      "phoneNumber": "1234567890"
    }
  ]
}
```

#### Get User Bookings
```http
GET /api/bookings
Authorization: Bearer <passenger-token>
```

#### Update Payment Status
```http
PUT /api/bookings/{bookingId}/payment
Authorization: Bearer <passenger-token>
```

---

## 📁 Project Structure

```
airline-management-system/
│
├── backend-java/                    # Spring Boot Backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/airline/
│   │   │   │   ├── config/          # Security & App Configuration
│   │   │   │   ├── controller/      # REST Controllers
│   │   │   │   ├── dto/             # Data Transfer Objects
│   │   │   │   ├── filter/          # JWT Authentication Filter
│   │   │   │   ├── model/           # JPA Entities
│   │   │   │   ├── repository/      # Data Repositories
│   │   │   │   └── service/         # Business Logic
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   └── test/
│   ├── pom.xml                      # Maven Dependencies
│   └── target/                      # Compiled JAR
│
├── frontend-angular/                # Angular Frontend
│   ├── src/
│   │   ├── app/
│   │   │   ├── components/
│   │   │   │   ├── login/
│   │   │   │   ├── admin-dashboard/
│   │   │   │   └── passenger-dashboard/
│   │   │   ├── guards/              # Route Guards
│   │   │   ├── interceptors/        # HTTP Interceptors
│   │   │   ├── models/              # TypeScript Interfaces
│   │   │   ├── services/            # API Services
│   │   │   ├── app.component.ts
│   │   │   ├── app.config.ts
│   │   │   └── app.routes.ts
│   │   ├── index.html
│   │   └── styles.css
│   ├── angular.json
│   ├── package.json
│   └── tsconfig.json
│
└── README.md
```

---

## 🐛 Troubleshooting

### Backend Issues

#### Port 8081 Already in Use
```bash
# Find and kill the process using port 8081
lsof -ti:8081 | xargs kill -9

# Or change the port in application.properties
server.port=8082
```

#### Database Connection Error
```
Error: Connection refused to MySQL
```

**Solution:**
1. Ensure MySQL is running:
   ```bash
   sudo service mysql status
   ```

2. Check credentials in `application.properties`

3. Verify database exists:
   ```bash
   mysql -u root -p -e "SHOW DATABASES;"
   ```

#### Tables Not Created
The application uses `spring.jpa.hibernate.ddl-auto=update` which automatically creates tables. If tables aren't created:

1. Check application logs for errors
2. Verify database permissions
3. Try setting `ddl-auto=create` (WARNING: This drops existing tables)

### Frontend Issues

#### Port 4200 Already in Use
```bash
# Kill the process
lsof -ti:4200 | xargs kill -9

# Or use a different port
ng serve --port 4300
```

#### CORS Errors
If you see CORS errors in browser console:

1. Backend CORS is configured for `http://localhost:4200`
2. If using a different port, update `SecurityConfig.java`:
   ```java
   configuration.setAllowedOrigins(Arrays.asList("http://localhost:4200", "http://localhost:4300"));
   ```

#### Module Not Found Errors
```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

#### Angular CLI Not Found
```bash
npm install -g @angular/cli@18
```

### General Issues

#### JWT Token Expired
Tokens expire after 24 hours. Simply log out and log in again.

#### "Admin" Button Disabled in Registration
This is intentional. In production, admin users should be created through a different process. For testing, you can select "Admin" from the dropdown.

---

## 📝 Additional Notes

### Sample Data

The application comes with 5 sample flights:
- AA101: New York → Los Angeles ($299.99)
- BA202: London → Paris ($149.99)
- UA303: San Francisco → Tokyo ($899.99)
- EK404: Dubai → Mumbai ($399.99)
- LH505: Berlin → Rome ($199.99)

### Mock Payment Gateway

The payment system is mocked for testing purposes. In production, you would integrate with:
- Stripe
- PayPal
- Razorpay
- Other payment providers

### Security Notes

1. **JWT Secret**: Change the JWT secret in production (`jwt.secret` in application.properties)
2. **Database Credentials**: Use environment variables for sensitive data
3. **HTTPS**: Always use HTTPS in production
4. **Password Hashing**: Passwords are automatically hashed using BCrypt

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Developer

Built with ❤️ using Java Spring Boot, MySQL, and Angular

---

## 📞 Support

For issues and questions:
- Create an issue in the repository
- Check the troubleshooting section above

---

**Happy Coding! ✈️**
