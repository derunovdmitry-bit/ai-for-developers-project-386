import "@typespec/http";

using Http;

@service(#{ title: "Calendar Booking API" })
@server("http://localhost:3000", "Local development server")
namespace CalendarBooking;

/** A single preconfigured owner profile used by the admin area and public booking pages. */
model CalendarOwnerProfile {
  id: string;
  displayName: string;
  description?: string;
  timezone: string;
}

/** A booking type that guests can choose before selecting an available slot. */
model EventType {
  id: string;

  @minLength(1)
  title: string;

  description: string;

  @minValue(1)
  durationMinutes: int32;
}

/** Request used by the owner to create an event type. */
model CreateEventTypeRequest {
  id: string;

  @minLength(1)
  title: string;

  description: string;

  @minValue(1)
  durationMinutes: int32;
}

/** A manually created owner availability interval for a concrete date and time range. */
model AvailabilityWindow {
  id: string;
  startsAt: utcDateTime;
  endsAt: utcDateTime;
}

/** Request used by the owner to create a manual availability interval. */
model CreateAvailabilityWindowRequest {
  startsAt: utcDateTime;
  endsAt: utcDateTime;
}

/** A slot generated from an availability window for the selected event type duration. */
model AvailableSlot {
  startsAt: utcDateTime;
  endsAt: utcDateTime;
  eventTypeId: string;
}

enum BookingStatus {
  confirmed,
  cancelled,
}

/** A confirmed guest booking. New bookings are created as confirmed in v1. */
model Booking {
  id: string;
  eventTypeId: string;
  eventTypeTitle: string;
  startsAt: utcDateTime;
  endsAt: utcDateTime;
  guestName: string;
  guestEmail: string;
  guestComment?: string;
  status: BookingStatus;
  createdAt: utcDateTime;
}

/** Request used by a guest to book one generated free slot. */
model CreateBookingRequest {
  eventTypeId: string;
  startsAt: utcDateTime;

  @minLength(1)
  guestName: string;

  @format("email")
  guestEmail: string;

  guestComment?: string;
}

/** Standard API error response. */
@error
model ApiError {
  code:
    | "event-type-not-found"
    | "availability-window-not-found"
    | "slot-outside-booking-window"
    | "slot-not-available"
    | "booking-conflict"
    | "validation-error";
  message: string;
}

model EventTypeList {
  items: EventType[];
}

model AvailabilityWindowList {
  items: AvailabilityWindow[];
}

model AvailableSlotList {
  items: AvailableSlot[];
}

model BookingList {
  items: Booking[];
}

@route("/public")
@tag("Public")
interface PublicApi {
  /** Get the single predefined calendar owner profile. */
  @get
  @route("/owner")
  getOwnerProfile(): CalendarOwnerProfile | ApiError;

  /** List event types visible to guests. */
  @get
  @route("/event-types")
  listEventTypes(): EventTypeList | ApiError;

  /**
   * List free slots for an event type within the next 14 days.
   * Slots are generated from manual availability windows using a step equal to the selected event type duration.
   */
  @get
  @route("/event-types/{eventTypeId}/slots")
  listAvailableSlots(@path eventTypeId: string): AvailableSlotList | ApiError;

  /**
   * Create a confirmed booking for a free generated slot.
   * The server calculates endsAt from the selected event type duration and rejects any interval overlap
   * with existing confirmed bookings, even when they belong to different event types.
   */
  @post
  @route("/bookings")
  createBooking(@body request: CreateBookingRequest): Booking | ApiError;
}

@route("/admin")
@tag("Admin")
interface AdminApi {
  /** Get the single predefined owner profile used by the admin area. */
  @get
  @route("/owner")
  getOwnerProfile(): CalendarOwnerProfile | ApiError;

  /** List all event types managed by the owner. */
  @get
  @route("/event-types")
  listEventTypes(): EventTypeList | ApiError;

  /** Create an event type with an owner-defined id, title, description, and duration. */
  @post
  @route("/event-types")
  createEventType(@body request: CreateEventTypeRequest): EventType | ApiError;

  /** List manually created availability windows. */
  @get
  @route("/availability-windows")
  listAvailabilityWindows(): AvailabilityWindowList | ApiError;

  /** Create a manual availability interval for a concrete date and time range. */
  @post
  @route("/availability-windows")
  createAvailabilityWindow(
    @body request: CreateAvailabilityWindowRequest
  ): AvailabilityWindow | ApiError;

  /** List upcoming confirmed bookings across all event types. */
  @get
  @route("/bookings/upcoming")
  listUpcomingBookings(): BookingList | ApiError;
}
