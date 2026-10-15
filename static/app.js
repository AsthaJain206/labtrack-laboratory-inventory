document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("form").forEach((form) => {
    form.addEventListener("submit", (event) => {
      if (form.dataset.confirm &&
          !window.confirm(form.dataset.confirm)) {
        event.preventDefault();
      }
    });
  });

  const today = new Date();
  const localDate = [
    today.getFullYear(),
    String(today.getMonth() + 1).padStart(2, "0"),
    String(today.getDate()).padStart(2, "0")
  ].join("-");

  document.querySelectorAll('input[type="date"]').forEach((input) => {
    if (!input.value && input.name === "issue_date") {
      input.value = localDate;
    }
  });
});
