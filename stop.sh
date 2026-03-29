#!/bin/bash

# Airline Management System - Stop Script
# Gracefully stops both backend and frontend servers

echo "========================================"
echo "  Stopping Airline Management System"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .app.pid file exists
if [ -f ".app.pid" ]; then
    echo "Reading PIDs from .app.pid..."
    PIDS=$(cat .app.pid)
    
    for PID in $PIDS; do
        if ps -p $PID > /dev/null; then
            echo "Stopping process $PID..."
            kill $PID
            sleep 2
            
            # Force kill if still running
            if ps -p $PID > /dev/null; then
                echo "Force stopping process $PID..."
                kill -9 $PID
            fi
        else
            echo "Process $PID not running"
        fi
    done
    
    rm .app.pid
    echo -e "${GREEN}✓${NC} Stopped processes from .app.pid"
else
    echo -e "${YELLOW}⚠${NC} .app.pid file not found. Searching for processes..."
fi

# Find and kill backend
echo ""
echo "Looking for backend processes..."
BACKEND_PIDS=$(pgrep -f "airline-management")

if [ ! -z "$BACKEND_PIDS" ]; then
    for PID in $BACKEND_PIDS; do
        echo "Stopping backend process $PID..."
        kill $PID 2>/dev/null
    done
    sleep 2
    
    # Force kill if still running
    BACKEND_PIDS=$(pgrep -f "airline-management")
    if [ ! -z "$BACKEND_PIDS" ]; then
        for PID in $BACKEND_PIDS; do
            echo "Force stopping backend process $PID..."
            kill -9 $PID 2>/dev/null
        done
    fi
    echo -e "${GREEN}✓${NC} Backend stopped"
else
    echo "No backend processes found"
fi

# Find and kill frontend
echo ""
echo "Looking for frontend processes..."
FRONTEND_PIDS=$(pgrep -f "ng serve")

if [ ! -z "$FRONTEND_PIDS" ]; then
    for PID in $FRONTEND_PIDS; do
        echo "Stopping frontend process $PID..."
        kill $PID 2>/dev/null
    done
    sleep 2
    
    # Force kill if still running
    FRONTEND_PIDS=$(pgrep -f "ng serve")
    if [ ! -z "$FRONTEND_PIDS" ]; then
        for PID in $FRONTEND_PIDS; do
            echo "Force stopping frontend process $PID..."
            kill -9 $PID 2>/dev/null
        done
    fi
    echo -e "${GREEN}✓${NC} Frontend stopped"
else
    echo "No frontend processes found"
fi

# Clean up log files (optional)
echo ""
read -p "Do you want to remove log files? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f backend.log frontend.log
    echo -e "${GREEN}✓${NC} Log files removed"
fi

echo ""
echo -e "${GREEN}Application stopped successfully!${NC}"
