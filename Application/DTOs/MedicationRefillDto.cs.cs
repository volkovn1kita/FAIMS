using System;

namespace Application.DTOs;

public class MedicationRefillDto
{
    public int AddedQuantity { get; set; }
    public DateTime NewExpirationDate { get; set; }
}