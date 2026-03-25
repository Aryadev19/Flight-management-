import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { FlightService } from '../../services/flight.service';
import { Flight } from '../../models/flight.model';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin-dashboard.component.html',
  styleUrl: './admin-dashboard.component.css'
})
export class AdminDashboardComponent implements OnInit {
  flights: Flight[] = [];
  currentUser: any;
  showAddFlight = false;
  showEditFlight = false;
  showPassengers = false;
  selectedFlight: Flight | null = null;
  passengers: any[] = [];
  
  newFlight: Flight = {
    flightNumber: '',
    origin: '',
    destination: '',
    departureTime: '',
    arrivalTime: '',
    availableSeats: 0,
    totalSeats: 0,
    price: 0,
    status: 'ACTIVE'
  };

  constructor(
    private authService: AuthService,
    private flightService: FlightService,
    private router: Router
  ) {}

  ngOnInit() {
    this.currentUser = this.authService.getCurrentUser();
    this.loadFlights();
  }

  loadFlights() {
    this.flightService.getFlights().subscribe({
      next: (data) => this.flights = data,
      error: (error) => console.error('Error loading flights:', error)
    });
  }

  openAddFlight() {
    this.showAddFlight = true;
    this.newFlight = {
      flightNumber: '',
      origin: '',
      destination: '',
      departureTime: '',
      arrivalTime: '',
      availableSeats: 0,
      totalSeats: 0,
      price: 0,
      status: 'ACTIVE'
    };
  }

  saveFlight() {
    this.flightService.createFlight(this.newFlight).subscribe({
      next: () => {
        this.showAddFlight = false;
        this.loadFlights();
        alert('Flight added successfully!');
      },
      error: (error) => alert('Error adding flight: ' + (error.error?.message || 'Unknown error'))
    });
  }

  editFlight(flight: Flight) {
    this.selectedFlight = { ...flight };
    this.showEditFlight = true;
  }

  updateFlight() {
    if (this.selectedFlight && this.selectedFlight.id) {
      this.flightService.updateFlight(this.selectedFlight.id, this.selectedFlight).subscribe({
        next: () => {
          this.showEditFlight = false;
          this.loadFlights();
          alert('Flight updated successfully!');
        },
        error: (error) => alert('Error updating flight: ' + (error.error?.message || 'Unknown error'))
      });
    }
  }

  deleteFlight(id: number | undefined) {
    if (id && confirm('Are you sure you want to delete this flight?')) {
      this.flightService.deleteFlight(id).subscribe({
        next: () => {
          this.loadFlights();
          alert('Flight deleted successfully!');
        },
        error: (error) => alert('Error deleting flight: ' + (error.error?.message || 'Unknown error'))
      });
    }
  }

  viewPassengers(flight: Flight) {
    if (flight.id) {
      this.selectedFlight = flight;
      this.flightService.getFlightPassengers(flight.id).subscribe({
        next: (data) => {
          this.passengers = data;
          this.showPassengers = true;
        },
        error: (error) => console.error('Error loading passengers:', error)
      });
    }
  }

  closeModal() {
    this.showAddFlight = false;
    this.showEditFlight = false;
    this.showPassengers = false;
    this.selectedFlight = null;
  }

  logout() {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}
