
document.querySelectorAll('input[name="SignLog"]').forEach(input => {
  input.addEventListener('change', function() {
    if (this.value === 'signup') {
      window.location.href = 'register.jsp';
    } else if (this.value === 'login') {
      window.location.href = 'login.jsp';
    }
  });
});

function route(id, url) {
  const btn = document.getElementById(id);
  if (btn) {
    btn.addEventListener('click', () => {
      window.location.href = url;
    });
  }
}

route('emplogbtn',  '../Employee/login.jsp');
route('custlogbtn', '../Customer/login.jsp');
route('custregbtn', '../Customer/register.jsp');


