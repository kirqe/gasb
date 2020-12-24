document.addEventListener("DOMContentLoaded", (event) => {
  let notification = document.querySelector(".notification")
  let close_btn = document.querySelector(".notification button")
  
  if (notification) {
    close_btn.addEventListener("click", () => { notification.remove() }, false)
    setTimeout(() => notification.remove(), 7000)
  }
})