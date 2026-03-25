import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Booking, BookingRequest } from '../models/booking.model';

@Injectable({
  providedIn: 'root'
})
export class BookingService {
  private apiUrl = 'http://localhost:8081/api/bookings';

  constructor(private http: HttpClient) {}

  createBooking(booking: BookingRequest): Observable<any> {
    return this.http.post(`${this.apiUrl}`, booking);
  }

  getUserBookings(): Observable<Booking[]> {
    return this.http.get<Booking[]>(`${this.apiUrl}`);
  }

  updatePaymentStatus(bookingId: number): Observable<any> {
    return this.http.put(`${this.apiUrl}/${bookingId}/payment`, {});
  }
}