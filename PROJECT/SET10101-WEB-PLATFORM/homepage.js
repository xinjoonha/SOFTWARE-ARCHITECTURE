// <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
// <script type="module">

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.13.2/firebase-app.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/10.13.2/firebase-analytics.js";
import {
  getFirestore,
  collection,
  query,
  where,
  getDocs,
  addDoc,
  Timestamp
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

document.getElementById('existingPatientNewDispatchButton').style.display = 'none';
document.getElementById('find-by-nhs-bottom-text').style.display = 'none';
document.getElementById('create-patient-bottom-text').style.display = 'none';
document.getElementById('refreshUIButton').style.display = 'none';

// Variable to store the found patient's NHS number
let foundPatientId = null;

// Function to generate a random NHS number
function generateRandomNHSNumber() {
    // NHS numbers are 10-digit numbers
    let nhsNumber = '';
    for (let i = 0; i < 10; i++) {
        nhsNumber += Math.floor(Math.random() * 10);
    }
    return nhsNumber;
}

// Function to generate a unique NHS number
async function generateUniqueNHSNumber() {
    let nhsNumber;
    let exists = true;
    while (exists) {
        nhsNumber = generateRandomNHSNumber();
        // Check if this NHS number already exists
        const patientsRef = collection(db, "patients");
        const q = query(patientsRef, where("patientId", "==", nhsNumber));
        const querySnapshot = await getDocs(q);
        exists = !querySnapshot.empty;
    }
    return nhsNumber;
}

// Function to reset the UI to its initial state
function resetUI() {
    // Get references to input fields
    const firstNameField = document.getElementById('first-name-field');
    const lastNameField = document.getElementById('last-name-field');
    const addressField = document.getElementById('address-field');
    const nhsNumberField = document.getElementById('nhs-number-field');
    const dateOfBirthField = document.getElementById('date-of-birth-field');
    const conditionField = document.getElementById('condition-field');

    // Clear input fields
    firstNameField.value = '';
    lastNameField.value = '';
    addressField.value = '';
    nhsNumberField.value = '';
    dateOfBirthField.value = '';
    conditionField.value = '';

    // Unlock input fields
    firstNameField.disabled = false;
    lastNameField.disabled = false;
    addressField.disabled = false;
    dateOfBirthField.disabled = false; // Unlock date of birth field

    // Reset buttons
    document.getElementById('createPatientButton').style.display = 'block';
    document.getElementById('existingPatientNewDispatchButton').style.display = 'none';
    document.getElementById('refreshUIButton').style.display = 'none';

    // Clear bottom text
    document.getElementById('find-by-nhs-bottom-text').innerText = '';

    // Reset foundPatientId
    foundPatientId = null;
}

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
    document.getElementById('find-by-nhs-bottom-text').style.display = 'flex';

    try {
        // Query Firestore for patients with the entered NHS number
        const patientsRef = collection(db, "patients");
        const q = query(patientsRef, where("patientId", "==", nhsNumber));
        const querySnapshot = await getDocs(q);

        // Get references to buttons
        const createPatientButton = document.getElementById('createPatientButton');
        const existingPatientButton = document.getElementById('existingPatientNewDispatchButton');
        const refreshUIButton = document.getElementById('refreshUIButton');

        // Get references to input fields
        const firstNameField = document.getElementById('first-name-field');
        const lastNameField = document.getElementById('last-name-field');
        const addressField = document.getElementById('address-field');
        const dateOfBirthField = document.getElementById('date-of-birth-field');

        // If no patient found
        if (querySnapshot.empty) {
            findByNhsBottomText.innerText = "Patient not found, create new patient below";

            // Show the create patient button, hide the existing patient button and refresh button
            createPatientButton.style.display = 'block';
            existingPatientButton.style.display = 'none';
            refreshUIButton.style.display = 'none';

            // Clear any pre-filled fields and unlock them
            firstNameField.value = '';
            lastNameField.value = '';
            addressField.value = '';
            dateOfBirthField.value = '';

            firstNameField.disabled = false;
            lastNameField.disabled = false;
            addressField.disabled = false;
            dateOfBirthField.disabled = false;

            // Reset foundPatientId
            foundPatientId = null;

            return;
        } else {
            // Patient found
            querySnapshot.forEach((doc) => {
                const patientData = doc.data();
                const patientId = patientData.patientId; // Use patientData.patientId

                // Update bottom text
                findByNhsBottomText.innerText = `Patient ${patientId} found, see details below`;

                // Prefill the fields
                firstNameField.value = patientData.firstName || '';
                lastNameField.value = patientData.lastName || '';
                addressField.value = patientData.address || '';

                // Handle date of birth
                const dateOfBirthTimestamp = patientData.dateOfBirth;
                let dateOfBirthStr = '';

                if (dateOfBirthTimestamp) {
                    const dateOfBirthDate = dateOfBirthTimestamp.toDate();
                    const day = String(dateOfBirthDate.getDate()).padStart(2, '0');
                    const month = String(dateOfBirthDate.getMonth() + 1).padStart(2, '0'); // Months are zero-based
                    const year = dateOfBirthDate.getFullYear();
                    dateOfBirthStr = `${day}-${month}-${year}`;
                }

                dateOfBirthField.value = dateOfBirthStr || '';

                // Lock the input fields
                firstNameField.disabled = true;
                lastNameField.disabled = true;
                addressField.disabled = true;
                dateOfBirthField.disabled = true;

                // Hide create patient button, show existing patient button and refresh button
                createPatientButton.style.display = 'none';
                existingPatientButton.style.display = 'block';
                refreshUIButton.style.display = 'block';

                // Store the found patientId
                foundPatientId = patientId;
            });
        }
    } catch (error) {
        console.error("Error fetching patient data:", error);
        alert("An error occurred while fetching patient data.");
    }
});

// Add event listener for the refresh button
document.getElementById('refreshUIButton').addEventListener('click', function(event) {
    event.preventDefault();

    // Reset the UI
    resetUI();
});

// Add event listener for the create patient button
document.getElementById('createPatientButton').addEventListener('click', async function(event) {
    event.preventDefault();

    // Get input values
    const firstName = document.getElementById('first-name-field').value.trim();
    const lastName = document.getElementById('last-name-field').value.trim();
    const dateOfBirthStr = document.getElementById('date-of-birth-field').value.trim();
    const address = document.getElementById('address-field').value.trim();
    const condition = document.getElementById('condition-field').value.trim();

    // Validate inputs
    if (!firstName || !lastName || !dateOfBirthStr || !address || !condition) {
        alert('Please fill in all required fields.');
        return;
    }

    // Convert dateOfBirth from string 'DD-MM-YYYY' to Date object
    const [day, month, year] = dateOfBirthStr.split('-');
    const dateOfBirth = new Date(`${year}-${month}-${day}`);
    if (isNaN(dateOfBirth)) {
        alert('Invalid date of birth. Please use DD-MM-YYYY format.');
        return;
    }

    try {
        // Generate a unique NHS number
        const nhsNumber = await generateUniqueNHSNumber();

        // Create patient document
        const patientData = {
            firstName,
            lastName,
            dateOfBirth: Timestamp.fromDate(dateOfBirth),
            address,
            patientId: nhsNumber
        };

        await addDoc(collection(db, 'patients'), patientData);

        // Create dispatch document
        const dispatchData = {
            date: Timestamp.now(),
            patientId: nhsNumber,
            status: 'pending',
            condition
        };

        await addDoc(collection(db, 'dispatches'), dispatchData);

        alert(`Patient and dispatch created successfully.\nAssigned NHS Number: ${nhsNumber}`);

        // Reset the UI
        resetUI();
    } catch (error) {
        console.error('Error creating patient and dispatch:', error);
        alert('An error occurred while creating the patient and dispatch.');
    }
});

// Add event listener for the existing patient new dispatch button
document.getElementById('existingPatientNewDispatchButton').addEventListener('click', async function(event) {
    event.preventDefault();

    // Get the condition from the 'condition-field'
    const condition = document.getElementById('condition-field').value.trim();

    // Validate that condition is not empty
    if (!condition) {
        alert('Please enter a condition.');
        return;
    }

    if (!foundPatientId) {
        alert('No patient selected.');
        return;
    }

    try {
        // Create dispatch document
        const dispatchData = {
            date: Timestamp.now(),
            patientId: foundPatientId,
            status: 'pending',
            condition
        };

        await addDoc(collection(db, 'dispatches'), dispatchData);

        alert('Dispatch created successfully.');

        // Reset the UI
        resetUI();
    } catch (error) {
        console.error('Error creating dispatch:', error);
        alert('An error occurred while creating the dispatch.');
    }
});

// </script>