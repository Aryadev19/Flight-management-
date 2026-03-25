import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Flight } from '../models/flight.model';

@Injectable({
  providedIn: 'root'
})
export class FlightService {
  private apiUrl = 'http://localhost:8081/api';

  constructor(private http: HttpClient) {}

  getAllFlights(): Observable<Flight[]> {
    return this.http.get<Flight[]>(`${this.apiUrl}/flights/all`);
  }

  getFlights(): Observable<Flight[]> {
    return this.http.get<Flight[]>(`${this.apiUrl}/flights`);
  }

  getFlightById(id: number): Observable<Flight> {
    return this.http.get<Flight>(`${this.apiUrl}/flights/${id}`);
  }

  createFlight(flight: Flight): Observable<any> {
    return this.http.post(`${this.apiUrl}/admin/flights`, flight);
  }

  updateFlight(id: number, flight: Flight): Observable<any> {
    return this.http.put(`${this.apiUrl}/admin/flights/${id}`, flight);
  }

  deleteFlight(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/admin/flights/${id}`);
  }

  getFlightPassengers(flightId: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/admin/flights/${flightId}/passengers`);
  }
}