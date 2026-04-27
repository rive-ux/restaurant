(function () {
  "use strict";

  var STORAGE_KEY = "restaurantReservations";

  function getReservations() {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];
    } catch (error) {
      return [];
    }
  }

  function saveReservations(reservations) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(reservations));
  }

  function addReservation(reservation) {
    var reservations = getReservations();
    var savedReservation = {
      id: Date.now().toString(),
      name: reservation.name || "",
      email: reservation.email || "",
      phone: reservation.phone || "",
      guests: reservation.guests || "",
      date: reservation.date || "",
      time: reservation.time || "",
      message: reservation.message || "",
      status: reservation.status || "E re",
      createdAt: reservation.createdAt || new Date().toISOString()
    };

    reservations.push(savedReservation);
    saveReservations(reservations);

    return savedReservation;
  }

  function updateStatus(id, status) {
    var reservations = getReservations().map(function (reservation) {
      if (reservation.id === id) {
        reservation.status = status;
      }

      return reservation;
    });

    saveReservations(reservations);
  }

  function removeReservation(id) {
    saveReservations(getReservations().filter(function (reservation) {
      return reservation.id !== id;
    }));
  }

  function getFieldValue(form, fieldName) {
    var field = form.elements[fieldName];
    return field ? field.value.trim() : "";
  }

  function isPlaceholder(value) {
    return value === "number-guests" || value === "time";
  }

  function showStatus(message, isError) {
    var status = document.getElementById("reservation-status");
    if (!status) {
      return;
    }

    status.textContent = message;
    status.style.display = "block";
    status.style.color = isError ? "#d62828" : "#2b9348";
    status.style.fontWeight = "600";
  }

  function buildReservation(form) {
    return {
      name: getFieldValue(form, "name"),
      email: getFieldValue(form, "email"),
      phone: getFieldValue(form, "phone"),
      guests: getFieldValue(form, "number-guests"),
      date: getFieldValue(form, "date"),
      time: getFieldValue(form, "time"),
      message: getFieldValue(form, "message")
    };
  }

  window.RestaurantReservations = {
    getAll: getReservations,
    add: addReservation,
    updateStatus: updateStatus,
    remove: removeReservation,
    clear: function () {
      saveReservations([]);
    }
  };

  document.addEventListener("DOMContentLoaded", function () {
    var form = document.getElementById("contact");

    if (!form) {
      return;
    }

    form.addEventListener("submit", function (event) {
      event.preventDefault();

      var reservation = buildReservation(form);

      if (!reservation.name || !reservation.email || !reservation.phone || !reservation.date || !reservation.message || isPlaceholder(reservation.guests) || isPlaceholder(reservation.time)) {
        showStatus("Ju lutem plotesoni te gjitha fushat para rezervimit.", true);
        return;
      }

      addReservation(reservation);

      form.reset();
      showStatus("Rezervimi u ruajt me sukses. Mund ta shihni ne Dashboard.", false);
    });
  });
})();
