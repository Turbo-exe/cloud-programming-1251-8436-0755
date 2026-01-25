const REGION_NAMES = [
    "eu", "us", "ap", "af"
]

// Function to detect the current region from the URL path
function getCurrentRegion() {
    const path = window.location.pathname;
    const regionPattern = new RegExp(`^\\/(${REGION_NAMES.join('|')})\\/`);
    const regionMatch = path.match(regionPattern);
    return regionMatch ? regionMatch[1] : null;
}


// Bind buttons to API calls
const serviceButtons = document.querySelectorAll('.service-button');
if (serviceButtons.length >= 2) {
    // First button calls send-email API
    serviceButtons[0].addEventListener("click", () => {
        callBackendAPI("send-email").then();
    });

    // Second button calls list-emails API (prod stage)
    serviceButtons[1].addEventListener("click", () => {
        callBackendAPI("list-emails").then();
    });

}


// Function to send a backend API call
async function callBackendAPI(endpointUrl) {
    const region = getCurrentRegion();
    if (!region) {
        let msg = "Region not detected in URL path";
        window.alert(msg);
        throw new Error(msg);
    }

    const apiUrl = `/${region}/prod/api/${endpointUrl}`;
    const response = await fetch(apiUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });

    if (!response.ok) {
        let msg = "Region not detected in URL path";
        window.alert(msg);
        throw new Error(msg);
    }

    const data = await response.json();
    window.alert("Backend service call successful! Response: " + JSON.stringify(data));
    console.log("Response of backend service #2: " + JSON.stringify(data))
}

// Wait for the DOM to be fully loaded
document.addEventListener('DOMContentLoaded', () => {
    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Mobile menu functionality
    const menuBtn = document.querySelector('.menu-btn');
    const navLinks = document.querySelector('.nav-links');
    let menuOpen = false;

    menuBtn?.addEventListener('click', () => {
        if (!menuOpen) {
            navLinks.style.display = 'flex';
            navLinks.style.flexDirection = 'column';
            navLinks.style.position = 'absolute';
            navLinks.style.top = '100%';
            navLinks.style.left = '0';
            navLinks.style.right = '0';
            navLinks.style.backgroundColor = 'white';
            navLinks.style.padding = '1rem';
            menuOpen = true;
        } else {
            navLinks.style.display = 'none';
            menuOpen = false;
        }
    });

    // Navbar background change on scroll
    window.addEventListener('scroll', () => {
        const nav = document.querySelector('nav');
        if (window.scrollY > 50) {
            nav.style.backgroundColor = 'rgba(255, 255, 255, 0.95)';
        } else {
            nav.style.backgroundColor = 'white';
        }
    });

    // Add animation to service cards when they come into view
    const observerOptions = {
        threshold: 0.2
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    document.querySelectorAll('.service-card').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        observer.observe(card);
    });

    // Add event listeners to service buttons
    const serviceButtons = document.querySelectorAll('.service-button');
    if (serviceButtons.length >= 2) {
        // First button calls send-email API
        serviceButtons[0].addEventListener('click', callSendEmailAPI);

        // Second button calls update-email API
        serviceButtons[1].addEventListener('click', callUpdateEmailAPI);
    }
});
