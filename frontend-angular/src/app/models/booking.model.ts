export interface Booking {
  id?: number;
  user: any;
  flight: any;
  bookingDate: string;
  paymentStatus: string;
  totalAmount: number;
  bookingReference: string;
  passengers: Passenger[];
}

export interface Passenger {
  id?: number;
  name: string;
  age: number;
  gender: string;
  email: string;
  phoneNumber: string;
  seatNumber?: string;
}

export interface BookingRequest {
  flightId: number;
  passengers: PassengerInfo[];
}

export interface PassengerInfo {
  name: string;
  age: number;
  gender: string;
  email: string;
  phoneNumber: string;
}