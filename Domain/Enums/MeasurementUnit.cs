using System.Text.Json.Serialization;
namespace Domain;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum MeasurementUnit
{
    Pieces,
    Milliliters,
    Grams,
    Tablets,
    Ampoules,
    Packs
}
