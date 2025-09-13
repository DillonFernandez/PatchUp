/**
 * Main site JavaScript
 * Handles login form submission and mobile navigation menu toggling.
 */

document.addEventListener("DOMContentLoaded", function () {
  // Handle login form submission and display feedback
  const form = document.getElementById("loginForm");
  const messageDiv = document.getElementById("loginMessage");
  if (form && messageDiv) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      messageDiv.textContent = "";
      const formData = new FormData(form);
      fetch("api/login.php", {
        method: "POST",
        body: formData,
      })
        .then((res) => res.json())
        .then((data) => {
          if (data.success) {
            messageDiv.classList.remove("text-red-600");
            messageDiv.classList.add("text-green-600");
            messageDiv.textContent = "Login successful! Redirecting...";
            setTimeout(() => {
              window.location.href = "index.php";
            }, 1200);
          } else {
            messageDiv.classList.remove("text-green-600");
            messageDiv.classList.add("text-red-600");
            messageDiv.textContent = data.message || "Login failed!";
          }
        })
        .catch(() => {
          messageDiv.classList.remove("text-green-600");
          messageDiv.classList.add("text-red-600");
          messageDiv.textContent = "An error occurred. Please try again.";
        });
    });
  }

  // Toggle mobile navigation sidebar and overlay
  const menuToggle = document.getElementById("menuToggle");
  const sidebar = document.getElementById("sidebar");
  const overlay = document.getElementById("overlay");

  if (menuToggle && sidebar && overlay) {
    menuToggle.addEventListener("click", () => {
      sidebar.classList.toggle("-translate-x-full");
      overlay.classList.toggle("hidden");
    });

    overlay.addEventListener("click", () => {
      sidebar.classList.add("-translate-x-full");
      overlay.classList.add("hidden");
    });
  }
});
