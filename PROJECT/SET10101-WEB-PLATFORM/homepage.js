
// <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
// <script type="module">

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.13.2/firebase-app.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/10.13.2/firebase-analytics.js";
import {
  getFirestore,
  collection,
  query,
  where,
  getDocs
} from "https://www.gstatic.com/firebasejs/10.13.2/firebase-firestore.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.13.2/firebase-auth.js";

const firebaseConfig = {
  apiKey: "AIzaSyDJZvkJV8HkbwZ-zkkngjwHpCCwmGOpazc",
  authDomain: "set10101.firebaseapp.com",
  projectId: "set10101",
  storageBucket: "set10101.appspot.com",
  messagingSenderId: "120649836638",
  appId: "1:120649836638:web:b582a723766798dd59accf",
  measurementId: "G-C4DML3W8B6"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);

document.getElementById('findByNHSButton').addEventListener('click', async function(event) {
    event.preventDefault();

    // Get the value from nhs-number-field
    const nhsNumber = document.getElementById('nhs-number-field').value.trim();

    // Alert and stop if empty value is provided
    if (!nhsNumber) {
        alert("Please enter an NHS number.");
        return;
    }

    const findByNhsBottomText = document.getElementById('find-by-nhs-bottom-text');

    try {
        // Query Firestore for patients with the entered NHS number
        const patientsRef = collection(db, "patients");
        const q = query(patientsRef, where("patientId", "==", nhsNumber));
        const querySnapshot = await getDocs(q);

        // Get references to buttons
        const createPatientButton = document.getElementById('createPatientButton');
        const existingPatientButton = document.getElementById('existingPatientNewDispatchButton');

        // Get references to input fields
        const firstNameField = document.getElementById('first-name-field');
        const lastNameField = document.getElementById('last-name-field');
        const addressField = document.getElementById('address-field');

        // If no patient found
        if (querySnapshot.empty) {
            findByNhsBottomText.innerText = "Patient not found, create new patient below";

            // Show the create patient button, hide the existing patient button
            createPatientButton.style.display = 'block';
            existingPatientButton.style.display = 'none';

            // Clear any pre-filled fields
            firstNameField.value = '';
            lastNameField.value = '';
            addressField.value = '';

            return;
        } else {
            // Patient found
            querySnapshot.forEach((doc) => {
                const patientData = doc.data();
                const patientId = patientData.patientId; // Use patientData.patientId instead of doc.id

                // Update bottom text
                findByNhsBottomText.innerText = `Patient ${patientId} found, see details below`;

                // Prefill the fields
                firstNameField.value = patientData.firstName || '';
                lastNameField.value = patientData.lastName || '';
                addressField.value = patientData.address || '';

                // Hide create patient button, show existing patient button
                createPatientButton.style.display = 'none';
                existingPatientButton.style.display = 'block';
            });
        }
    } catch (error) {
        console.error("Error fetching patient data:", error);
        alert("An error occurred while fetching patient data.");
    }
});

// </script>