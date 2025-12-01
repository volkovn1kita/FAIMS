using System.Text.Json.Serialization;
namespace Domain;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum JournalAction
{
    Added,
    Removed,
    QuantityChanged,
    Expired,
    Used,
    WrittenOff
}
