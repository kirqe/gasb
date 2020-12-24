document.addEventListener("DOMContentLoaded", (event) => {

  let notification = document.querySelector(".notification")
  let close_btn = document.querySelector(".notification button")
  close_btn.addEventListener("click", () => { notification.remove() }, false)
  if (notification) {
    setTimeout(() => notification.remove(), 7000)
  }
})