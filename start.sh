#!/bin/bash

# Airline Management System - Quick Start Script
# This script helps you set up and run the application quickly

echo "========================================"
echo "  Airline Management System Setup"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Java
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo -e "${GREEN}✓${NC} Java installed: $JAVA_VERSION"
else
    echo -e "${RED}✗${NC} Java not found. Please install JDK 17 or higher"
    exit 1
fi

# Check Maven
if command_exists mvn; then
    MVN_VERSION=$(mvn -version | grep "Apache Maven" | awk '{print $3}')
    echo -e "${GREEN}✓${NC} Maven installed: $MVN_VERSION"
else
    echo -e "${RED}✗${NC} Maven not found. Please install Maven 3.6+"
    exit 1
fi

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓${NC} Node.js installed: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js not found. Please install Node.js 20+"
    exit 1
fi

# Check npm
if command_exists npm; then
    NPM_VERSION=$(npm -v)
    echo -e "${GREEN}✓${NC} npm installed: $NPM_VERSION"
else
    echo -e "${RED}✗${NC} npm not found. Please install npm"
    exit 1
fi

# Check MySQL
if command_exists mysql; then
    MYSQL_VERSION=$(mysql --version | awk '{print $5}' | sed 's/,$//')
    echo -e "${GREEN}✓${NC} MySQL installed: $MYSQL_VERSION"
else
    echo -e "${YELLOW}⚠${NC} MySQL not found. Make sure MySQL/MariaDB is installed"
fi

# Check Angular CLI
if command_exists ng; then
    NG_VERSION=$(ng version --no-update-notifier 2>/dev/null | grep "Angular CLI" | awk '{print $3}')
    echo -e "${GREEN}✓${NC} Angular CLI installed: $NG_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Angular CLI not found. Installing globally..."
    npm install -g @angular/cli@18
fi

echo ""
echo "========================================"
echo "  Database Setup"
echo "========================================"
echo ""

# Check if MySQL is running
if pgrep -x "mysqld" > /dev/null || pgrep -x "mariadbd" > /dev/null; then
    echo -e "${GREEN}✓${NC} MySQL/MariaDB is running"
else
    echo -e "${YELLOW}⚠${NC} MySQL/MariaDB is not running"
    echo "Starting MySQL/MariaDB..."
    
    if command_exists systemctl; then
        sudo systemctl start mysql 2>/dev/null || sudo systemctl start mariadb 2>/dev/null
    elif command_exists service; then
        sudo service mysql start 2>/dev/null || sudo service mariadb start 2>/dev/null
    else
        echo -e "${RED}✗${NC} Could not start MySQL. Please start it manually"
        exit 1
    fi
fi

echo ""
read -p "Do you want to set up the database? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Setting up database..."
    
    mysql -u root -p << EOF
CREATE DATABASE IF NOT EXISTS airline_management;
CREATE USER IF NOT EXISTS 'airlineuser'@'localhost' IDENTIFIED BY 'airline@2026';
GRANT ALL PRIVILEGES ON airline_management.* TO 'airlineuser'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Database setup complete"
    else
        echo -e "${RED}✗${NC} Database setup failed"
        exit 1
    fi
fi

echo ""
echo "========================================"
echo "  Backend Setup"
echo "========================================"
echo ""

if [ -d "backend-java" ]; then
    cd backend-java
    
    if [ -f "target/airline-management-1.0.0.jar" ]; then
        echo -e "${GREEN}✓${NC} Backend JAR already exists"
    else
        echo "Building backend..."
        mvn clean install -DskipTests
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓${NC} Backend build complete"
        else
            echo -e "${RED}✗${NC} Backend build failed"
            exit 1
        fi
    fi
    
    cd ..
else
    echo -e "${RED}✗${NC} backend-java directory not found"
    exit 1
fi

echo ""
echo "========================================"
echo "  Frontend Setup"
echo "========================================"
echo ""

if [ -d "frontend-angular" ]; then
    cd frontend-angular
    
    if [ -d "node_modules" ]; then
        echo -e "${GREEN}✓${NC} Node modules already installed"
    else
        echo "Installing frontend dependencies..."
        npm install
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓${NC} Frontend dependencies installed"
        else
            echo -e "${RED}✗${NC} Frontend installation failed"
            exit 1
        fi
    fi
    
    cd ..
else
    echo -e "${RED}✗${NC} frontend-angular directory not found"
    exit 1
fi

echo ""
echo "========================================"
echo "  Starting Application"
echo "========================================"
echo ""

# Start backend
echo "Starting backend server..."
cd backend-java
java -jar target/airline-management-1.0.0.jar > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

echo "Backend started (PID: $BACKEND_PID)"
echo "Waiting for backend to initialize..."
sleep 15

# Check if backend is running
if ps -p $BACKEND_PID > /dev/null; then
    echo -e "${GREEN}✓${NC} Backend is running on http://localhost:8081"
else
    echo -e "${RED}✗${NC} Backend failed to start. Check backend.log for details"
    exit 1
fi

# Create admin user and sample data
echo ""
echo "Creating admin user and sample flights..."
sleep 5

curl -s -X POST "http://localhost:8081/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@airline.com","password":"admin123","name":"Admin User","role":"ADMIN"}' > /dev/null

curl -s -X POST "http://localhost:8081/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"passenger@test.com","password":"pass123","name":"Test Passenger","role":"PASSENGER"}' > /dev/null

# Get admin token and add flights
ADMIN_TOKEN=$(curl -s -X POST "http://localhost:8081/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@airline.com","password":"admin123"}' | python3 -c "import sys,json;print(json.load(sys.stdin)['token'])" 2>/dev/null)

if [ ! -z "$ADMIN_TOKEN" ]; then
    # Add sample flights
    curl -s -X POST "http://localhost:8081/api/admin/flights" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -d '{"flightNumber":"AA101","origin":"New York","destination":"Los Angeles","departureTime":"2026-04-01T08:00:00","arrivalTime":"2026-04-01T11:30:00","totalSeats":180,"availableSeats":180,"price":299.99,"status":"ACTIVE"}' > /dev/null
    
    curl -s -X POST "http://localhost:8081/api/admin/flights" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -d '{"flightNumber":"BA202","origin":"London","destination":"Paris","departureTime":"2026-04-02T10:00:00","arrivalTime":"2026-04-02T11:15:00","totalSeats":150,"availableSeats":150,"price":149.99,"status":"ACTIVE"}' > /dev/null
    
    echo -e "${GREEN}✓${NC} Sample data created"
fi

# Start frontend
echo ""
echo "Starting frontend server..."
cd frontend-angular
ng serve --host 0.0.0.0 --port 4200 > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

echo "Frontend started (PID: $FRONTEND_PID)"
echo "Waiting for frontend to compile..."
sleep 25

# Check if frontend is running
if ps -p $FRONTEND_PID > /dev/null; then
    echo -e "${GREEN}✓${NC} Frontend is running on http://localhost:4200"
else
    echo -e "${RED}✗${NC} Frontend failed to start. Check frontend.log for details"
    kill $BACKEND_PID
    exit 1
fi

echo ""
echo "========================================"
echo "  ✓ Application is Ready!"
echo "========================================"
echo ""
echo "Frontend: http://localhost:4200"
echo "Backend:  http://localhost:8081/api"
echo ""
echo "Test Credentials:"
echo "  Admin:     admin@airline.com / admin123"
echo "  Passenger: passenger@test.com / pass123"
echo ""
echo "Logs:"
echo "  Backend:  backend.log"
echo "  Frontend: frontend.log"
echo ""
echo "To stop the application:"
echo "  kill $BACKEND_PID $FRONTEND_PID"
echo ""
echo "Saving PIDs to .app.pid for easy cleanup..."
echo "$BACKEND_PID $FRONTEND_PID" > .app.pid

echo -e "${GREEN}Happy Coding! ✈️${NC}"
