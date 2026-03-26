import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { FlightService } from '../../services/flight.service';
import { BookingService } from '../../services/booking.service';
import { Flight } from '../../models/flight.model';
import { BookingRequest, PassengerInfo, Booking } from '../../models/booking.model';

@Component({
  selector: 'app-passenger-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './passenger-dashboard.component.html',
  styleUrl: './passenger-dashboard.component.css'
})
export class PassengerDashboardComponent implements OnInit {
  currentUser: any;
  flights: Flight[] = [];
  myBookings: Booking[] = [];
  showBookingForm = false;
  showPayment = false;
  selectedFlight: Flight | null = null;
  passengerCount = 1;
  passengers: PassengerInfo[] = [];
  currentBooking: any = null;

  constructor(
    private authService: AuthService,
    private flightService: FlightService,
    private bookingService: BookingService,
    private router: Router
  ) {}

  ngOnInit() {
    this.currentUser = this.authService.getCurrentUser();
    this.loadFlights();
    this.loadMyBookings();
  }

  loadFlights() {
    this.flightService.getAllFlights().subscribe({
      next: (data) => this.flights = data.filter(f => f.status === 'ACTIVE' && f.availableSeats > 0),
      error: (error) => console.error('Error loading flights:', error)
    });
  }

  loadMyBookings() {
    this.bookingService.getUserBookings().subscribe({
      next: (data) => this.myBookings = data,
      error: (error) => console.error('Error loading bookings:', error)
    });
  }

  bookFlight(flight: Flight) {
    this.selectedFlight = flight;
    this.showBookingForm = true;
    this.passengerCount = 1;
    this.initializePassengers();
  }

  initializePassengers() {
    this.passengers = [];
    for (let i = 0; i < this.passengerCount; i++) {
      this.passengers.push({
        name: '',
        age: 0,
        gender: 'Male',
        email: '',
        phoneNumber: ''
      });
    }
  }

  updatePassengerCount() {
    if (this.selectedFlight && this.passengerCount > this.selectedFlight.availableSeats) {
      alert(`Only ${this.selectedFlight.availableSeats} seats available!`);
      this.passengerCount = this.selectedFlight.availableSeats;
    }
    this.initializePassengers();
  }

  submitBooking() {
    if (!this.selectedFlight) return;

    const bookingRequest: BookingRequest = {
      flightId: this.selectedFlight.id!,
      passengers: this.passengers
    };

    this.bookingService.createBooking(bookingRequest).subscribe({
      next: (response) => {
        this.currentBooking = response.data;
        this.showBookingForm = false;
        this.showPayment = true;
      },
      error: (error) => alert('Booking failed: ' + (error.error?.message || 'Unknown error'))
    });
  }

  completePayment() {
    if (this.currentBooking && this.currentBooking.id) {
      this.bookingService.updatePaymentStatus(this.currentBooking.id).subscribe({
        next: () => {
          alert('Payment completed successfully! Booking confirmed.');
          this.showPayment = false;
          this.loadMyBookings();
          this.loadFlights();
        },
        error: (error) => alert('Payment failed: ' + (error.error?.message || 'Unknown error'))
      });
    }
  }

  closeModal() {
    this.showBookingForm = false;
    this.showPayment = false;
    this.selectedFlight = null;
    this.currentBooking = null;
  }

  logout() {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}
