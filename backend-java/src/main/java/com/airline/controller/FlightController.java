package com.airline.controller;

import com.airline.dto.ApiResponse;
import com.airline.model.Flight;
import com.airline.repository.FlightRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class FlightController {

    @Autowired
    private FlightRepository flightRepository;

    @GetMapping("/flights/all")
    public ResponseEntity<List<Flight>> getAllFlights() {
        List<Flight> flights = flightRepository.findByStatus("ACTIVE");
        return ResponseEntity.ok(flights);
    }

    @GetMapping("/flights")
    @PreAuthorize("hasAnyRole('ADMIN', 'PASSENGER')")
    public ResponseEntity<List<Flight>> getFlights() {
        List<Flight> flights = flightRepository.findAll();
        return ResponseEntity.ok(flights);
    }

    @GetMapping("/flights/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PASSENGER')")
    public ResponseEntity<?> getFlightById(@PathVariable Long id) {
        return flightRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/admin/flights")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createFlight(@RequestBody Flight flight) {
        try {
            if (flightRepository.existsByFlightNumber(flight.getFlightNumber())) {
                return ResponseEntity.badRequest()
                        .body(new ApiResponse("Flight number already exists"));
            }
            flight.setStatus("ACTIVE");
            Flight savedFlight = flightRepository.save(flight);
            return ResponseEntity.ok(new ApiResponse("Flight created successfully", savedFlight));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse("Failed to create flight: " + e.getMessage()));
        }
    }

    @PutMapping("/admin/flights/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateFlight(@PathVariable Long id, @RequestBody Flight flightDetails) {
        return flightRepository.findById(id)
                .map(flight -> {
                    flight.setFlightNumber(flightDetails.getFlightNumber());
                    flight.setOrigin(flightDetails.getOrigin());
                    flight.setDestination(flightDetails.getDestination());
                    flight.setDepartureTime(flightDetails.getDepartureTime());
                    flight.setArrivalTime(flightDetails.getArrivalTime());
                    flight.setAvailableSeats(flightDetails.getAvailableSeats());
                    flight.setTotalSeats(flightDetails.getTotalSeats());
                    flight.setPrice(flightDetails.getPrice());
                    flight.setStatus(flightDetails.getStatus());
                    Flight updatedFlight = flightRepository.save(flight);
                    return ResponseEntity.ok(new ApiResponse("Flight updated successfully", updatedFlight));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/admin/flights/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteFlight(@PathVariable Long id) {
        return flightRepository.findById(id)
                .map(flight -> {
                    flightRepository.delete(flight);
                    return ResponseEntity.ok(new ApiResponse("Flight deleted successfully"));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}