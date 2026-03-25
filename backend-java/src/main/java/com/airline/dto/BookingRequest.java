package com.airline.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BookingRequest {
    private Long flightId;
    private List<PassengerInfo> passengers;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PassengerInfo {
        private String name;
        private Integer age;
        private String gender;
        private String email;
        private String phoneNumber;
    }
}