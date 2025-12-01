namespace Application.DTOs;

public record MedicationStatDto(
    string MedicationName, 
    double TotalQuantity, 
    string Unit
);
