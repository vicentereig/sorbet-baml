import "../styles/index.css"
import Plausible from 'plausible-tracker'

// Initialize Plausible Analytics
const plausible = Plausible({
  domain: 'vicentereig.github.io'
})

// Track page views automatically
plausible.trackPageview()

// Mobile menu toggle
document.addEventListener('DOMContentLoaded', function() {
  const mobileMenuButton = document.getElementById('mobile-menu-button');
  const mobileMenu = document.getElementById('mobile-menu');
  
  if (mobileMenuButton && mobileMenu) {
    mobileMenuButton.addEventListener('click', function() {
      mobileMenu.classList.toggle('hidden');
    });
  }
});