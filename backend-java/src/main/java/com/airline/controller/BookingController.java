package com.airline.controller;

import com.airline.dto.ApiResponse;
import com.airline.dto.BookingRequest;
import com.airline.model.Booking;
import com.airline.model.Flight;
import com.airline.model.Passenger;
import com.airline.model.User;
import com.airline.repository.BookingRepository;
import com.airline.repository.FlightRepository;
import com.airline.repository.PassengerRepository;
import com.airline.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class BookingController {

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private FlightRepository flightRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PassengerRepository passengerRepository;

    @PostMapping("/bookings")
    @PreAuthorize("hasRole('PASSENGER')")
    public ResponseEntity<?> createBooking(@RequestBody BookingRequest request) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String userEmail = authentication.getName();

            User user = userRepository.findByEmail(userEmail)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            Flight flight = flightRepository.findById(request.getFlightId())
                    .orElseThrow(() -> new RuntimeException("Flight not found"));

            int passengerCount = request.getPassengers().size();
            if (flight.getAvailableSeats() < passengerCount) {
                return ResponseEntity.badRequest()
                        .body(new ApiResponse("Not enough seats available"));
            }

            Booking booking = new Booking();
            booking.setUser(user);
            booking.setFlight(flight);
            booking.setBookingDate(LocalDateTime.now());
            booking.setPaymentStatus("PENDING");
            booking.setTotalAmount(flight.getPrice() * passengerCount);
            booking.setBookingReference("BK" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());

            Booking savedBooking = bookingRepository.save(booking);

            List<Passenger> passengers = new ArrayList<>();
            int seatCounter = flight.getTotalSeats() - flight.getAvailableSeats() + 1;

            for (BookingRequest.PassengerInfo passengerInfo : request.getPassengers()) {
                Passenger passenger = new Passenger();
                passenger.setBooking(savedBooking);
                passenger.setName(passengerInfo.getName());
                passenger.setAge(passengerInfo.getAge());
                passenger.setGender(passengerInfo.getGender());
                passenger.setEmail(passengerInfo.getEmail());
                passenger.setPhoneNumber(passengerInfo.getPhoneNumber());
                passenger.setSeatNumber(String.format("%d%c", (seatCounter / 6) + 1, (char) ('A' + (seatCounter % 6))));
                passengers.add(passenger);
                seatCounter++;
            }

            passengerRepository.saveAll(passengers);

            flight.setAvailableSeats(flight.getAvailableSeats() - passengerCount);
            flightRepository.save(flight);

            savedBooking.setPassengers(passengers);

            return ResponseEntity.ok(new ApiResponse("Booking created successfully", savedBooking));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse("Booking failed: " + e.getMessage()));
        }
    }

    @GetMapping("/bookings")
    @PreAuthorize("hasRole('PASSENGER')")
    public ResponseEntity<List<Booking>> getUserBookings() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Booking> bookings = bookingRepository.findByUserId(user.getId());
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/admin/flights/{flightId}/passengers")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getFlightPassengers(@PathVariable Long flightId) {
        List<Booking> bookings = bookingRepository.findByFlightId(flightId);
        List<Passenger> allPassengers = new ArrayList<>();

        for (Booking booking : bookings) {
            allPassengers.addAll(booking.getPassengers());
        }

        return ResponseEntity.ok(allPassengers);
    }

    @PutMapping("/bookings/{id}/payment")
    @PreAuthorize("hasRole('PASSENGER')")
    public ResponseEntity<?> updatePaymentStatus(@PathVariable Long id) {
        return bookingRepository.findById(id)
                .map(booking -> {
                    booking.setPaymentStatus("COMPLETED");
                    bookingRepository.save(booking);
                    return ResponseEntity.ok(new ApiResponse("Payment completed successfully", booking));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}