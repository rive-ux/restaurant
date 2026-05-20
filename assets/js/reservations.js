(function () {
  "use strict";

  var STORAGE_KEY = "restaurantReservations";
  var API_BASE_URL = window.RESTAURANT_API_URL || "http://localhost:3000/api";

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
      createdAt: reservation.createdAt || new Date().toISOString(),
      source: "browser"
    };

    reservations.push(savedReservation);
    saveReservations(reservations);

    return savedReservation;
  }

  function updateStatus(id, status) {
    var updatedReservation;
    var reservations = getReservations().map(function (reservation) {
      if (reservation.id === id) {
        reservation.status = status;
        updatedReservation = reservation;
      }

      return reservation;
    });

    saveReservations(reservations);
    return updatedReservation;
  }

  function removeReservation(id) {
    saveReservations(getReservations().filter(function (reservation) {
      return reservation.id !== id;
    }));
  }

  function normalizeReservation(reservation) {
    return {
      id: String(reservation.id || reservation.rezervim_id || Date.now()),
      name: reservation.name || reservation.emri || reservation.klienti || "",
      email: reservation.email || "",
      phone: reservation.phone || reservation.telefoni || "",
      guests: reservation.guests || reservation.numri_personave || "",
      date: reservation.date || reservation.data_rezervimit || "",
      time: reservation.time || reservation.ora_rezervimit || "",
      message: reservation.message || reservation.mesazhi || "",
      status: reservation.status || reservation.statusi || "E re",
      createdAt: reservation.createdAt || reservation.krijuar_me || "",
      source: reservation.source || "database"
    };
  }

  function requestJson(path, options) {
    return fetch(API_BASE_URL + path, options).then(function (response) {
      if (!response.ok) {
        throw new Error("API request failed");
      }

      return response.json();
    });
  }

  function getAllFromApi() {
    return requestJson("/rezervime").then(function (reservations) {
      return reservations.map(normalizeReservation);
    });
  }

  function addToApi(reservation) {
    return requestJson("/rezervime", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(reservation)
    }).then(normalizeReservation);
  }

  function updateStatusInApi(id, status) {
    return requestJson("/rezervime/" + encodeURIComponent(id) + "/status", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ status: status })
    }).then(normalizeReservation);
  }

  function removeFromApi(id) {
    return requestJson("/rezervime/" + encodeURIComponent(id), {
      method: "DELETE"
    });
  }

  function clearApi() {
    return fetch(API_BASE_URL + "/rezervime", {
      method: "DELETE"
    }).then(function (response) {
      if (!response.ok) {
        throw new Error("API request failed");
      }
    });
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
    getLocal: function () {
      return Promise.resolve(getReservations());
    },
    getAll: function () {
      return getAllFromApi().catch(function () {
        return getReservations();
      });
    },
    add: function (reservation) {
      return addToApi(reservation).catch(function () {
        return addReservation(reservation);
      });
    },
    updateStatus: function (id, status) {
      return updateStatusInApi(id, status).catch(function () {
        return updateStatus(id, status);
      });
    },
    remove: function (id) {
      return removeFromApi(id).catch(function () {
        removeReservation(id);
      });
    },
    clear: function () {
      return clearApi().catch(function () {
        saveReservations([]);
      });
    },
    getAllRemote: getAllFromApi,
    addRemote: addToApi,
    updateStatusRemote: updateStatusInApi,
    removeRemote: removeFromApi
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

      window.RestaurantReservations.add(reservation).then(function (savedReservation) {
        form.reset();
        if (savedReservation && savedReservation.source === "browser") {
          showStatus("Backend-i nuk eshte aktiv. Rezervimi u ruajt perkohesisht ne browser.", false);
        } else {
          showStatus("Rezervimi u ruajt ne databaze me sukses. Mund ta shihni ne Dashboard.", false);
        }
      });
    });
  });
})();
