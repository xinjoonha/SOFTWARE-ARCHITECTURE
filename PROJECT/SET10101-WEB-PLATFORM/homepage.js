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

// INITIALIZE FIREBASE CONFIGURATION
const firebaseConfig = {
  apiKey: "AIzaSyDJZvkJV8HkbwZ-zkkngjwHpCCwmGOpazc",
  authDomain: "set10101.firebaseapp.com",
  projectId: "set10101",
  storageBucket: "set10101.appspot.com",
  messagingSenderId: "120649836638",
  appId: "1:120649836638:web:b582a723766798dd59accf",
  measurementId: "G-C4DML3W8B6"
};

// INITIALIZE FIREBASE
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);

// HIDE SPECIFIC UI ELEMENTS INITIALLY
document.getElementById('existingPatientNewDispatchButton').style.display = 'none';
document.getElementById('find-by-nhs-bottom-text').style.display = 'none';
document.getElementById('create-patient-bottom-text').style.display = 'none';
document.getElementById('refreshUIButton').style.display = 'none';

// VARIABLE TO STORE THE FOUND PATIENT'S NHS NUMBER
let foundPatientId = null;

// FUNCTION TO GENERATE A RANDOM NHS NUMBER
function generateRandomNHSNumber() {
    // GENERATE A 10-DIGIT NHS NUMBER
    let nhsNumber = '';
    for (let i = 0; i < 10; i++) {
        nhsNumber += Math.floor(Math.random() * 10);
    }
    return nhsNumber;
}

// FUNCTION TO GENERATE A UNIQUE NHS NUMBER
async function generateUniqueNHSNumber() {
    let nhsNumber;
    let exists = true;
    while (exists) {
        nhsNumber = generateRandomNHSNumber();
        // CHECK IF THE NHS NUMBER ALREADY EXISTS
        const patientsRef = collection(db, "patients");
        const q = query(patientsRef, where("patientId", "==", nhsNumber));
        const querySnapshot = await getDocs(q);
        exists = !querySnapshot.empty;
    }
    return nhsNumber;
}

// FUNCTION TO RESET THE UI TO ITS INITIAL STATE
function resetUI() {
    // GET REFERENCES TO INPUT FIELDS
    const firstNameField = document.getElementById('first-name-field');
    const lastNameField = document.getElementById('last-name-field');
    const addressField = document.getElementById('address-field');
    const nhsNumberField = document.getElementById('nhs-number-field');
    const dateOfBirthField = document.getElementById('date-of-birth-field');
    const conditionField = document.getElementById('condition-field');

    // CLEAR INPUT FIELDS
    firstNameField.value = '';
    lastNameField.value = '';
    addressField.value = '';
    nhsNumberField.value = '';
    dateOfBirthField.value = '';
    conditionField.value = '';

    // UNLOCK INPUT FIELDS
    firstNameField.disabled = false;
    lastNameField.disabled = false;
    addressField.disabled = false;
    dateOfBirthField.disabled = false;

    // RESET BUTTONS
    document.getElementById('createPatientButton').style.display = 'block';
    document.getElementById('existingPatientNewDispatchButton').style.display = 'none';
    document.getElementById('refreshUIButton').style.display = 'none';

    // CLEAR BOTTOM TEXT
    document.getElementById('find-by-nhs-bottom-text').innerText = '';

    // RESET FOUND PATIENT ID
    foundPatientId = null;
}

// ADD EVENT LISTENER TO FIND BY NHS BUTTON
document.getElementById('findByNHSButton').addEventListener('click', async function(event) {
    event.preventDefault();

    // GETTING THE VALUE FROM: nhs-number-field
    const nhsNumber = document.getElementById('nhs-number-field').value.trim();

    // ALERT AND STOP IF EMPTY VALUE IS PROVIDED
    if (!nhsNumber) {
        alert("Please enter an NHS number.");
        return;
    }

    const findByNhsBottomText = document.getElementById('find-by-nhs-bottom-text');
    document.getElementById('find-by-nhs-bottom-text').style.display = 'flex';

    try {
        // QUERY FIRESTORE FOR PATIENTS WITH THE ENTERED NHS NUMBER
        const patientsRef = collection(db, "patients");
        const q = query(patientsRef, where("patientId", "==", nhsNumber));
        const querySnapshot = await getDocs(q);

        // GET REFERENCES TO BUTTONS
        const createPatientButton = document.getElementById('createPatientButton');
        const existingPatientButton = document.getElementById('existingPatientNewDispatchButton');
        const refreshUIButton = document.getElementById('refreshUIButton');

        // GET REFERENCES TO INPUT FIELDS
        const firstNameField = document.getElementById('first-name-field');
        const lastNameField = document.getElementById('last-name-field');
        const addressField = document.getElementById('address-field');
        const dateOfBirthField = document.getElementById('date-of-birth-field');

        // IF NO PATIENT IS FOUND
        if (querySnapshot.empty) {
            findByNhsBottomText.innerText = "Patient not found, create new patient below";

            // SHOW THE CREATE PATIENT BUTTON, HIDE THE EXISTING PATIENT BUTTON AND REFRESH BUTTON
            createPatientButton.style.display = 'block';
            existingPatientButton.style.display = 'none';
            refreshUIButton.style.display = 'none';

            // CLEAR ANY PRE-FILLED FIELDS AND UNLOCK THEM
            firstNameField.value = '';
            lastNameField.value = '';
            addressField.value = '';
            dateOfBirthField.value = '';

            firstNameField.disabled = false;
            lastNameField.disabled = false;
            addressField.disabled = false;
            dateOfBirthField.disabled = false;

            // RESET FOUND PATIENT ID
            foundPatientId = null;

            return;
        } else {
            // PATIENT FOUND
            querySnapshot.forEach((doc) => {
                const patientData = doc.data();
                const patientId = patientData.patientId; // USE PATIENT ID FROM DOCUMENT DATA

                // UPDATE BOTTOM TEXT
                findByNhsBottomText.innerText = `Patient ${patientId} found, see details below`;

                // PREFILL THE FIELDS
                firstNameField.value = patientData.firstName || '';
                lastNameField.value = patientData.lastName || '';
                addressField.value = patientData.address || '';

                // HANDLE DATE OF BIRTH
                const dateOfBirthTimestamp = patientData.dateOfBirth;
                let dateOfBirthStr = '';

                if (dateOfBirthTimestamp) {
                    const dateOfBirthDate = dateOfBirthTimestamp.toDate();
                    const day = String(dateOfBirthDate.getDate()).padStart(2, '0');
                    const month = String(dateOfBirthDate.getMonth() + 1).padStart(2, '0'); // MONTHS ARE ZERO-BASED
                    const year = dateOfBirthDate.getFullYear();
                    dateOfBirthStr = `${day}-${month}-${year}`;
                }

                dateOfBirthField.value = dateOfBirthStr || '';

                // LOCK THE INPUT FIELDS
                firstNameField.disabled = true;
                lastNameField.disabled = true;
                addressField.disabled = true;
                dateOfBirthField.disabled = true;

                // HIDE CREATE PATIENT BUTTON, SHOW EXISTING PATIENT BUTTON AND REFRESH BUTTON
                createPatientButton.style.display = 'none';
                existingPatientButton.style.display = 'block';
                refreshUIButton.style.display = 'block';

                // STORE THE FOUND PATIENT ID
                foundPatientId = patientId;
            });
        }
    } catch (error) {
        console.error("Error fetching patient data:", error);
        alert("An error occurred while fetching patient data.");
    }
});

// ADD EVENT LISTENER FOR REFRESH BUTTON
document.getElementById('refreshUIButton').addEventListener('click', function(event) {
    event.preventDefault();

    // RESET THE UI
    resetUI();
});

// ADD EVENT LISTENER FOR CREATE PATIENT BUTTON
document.getElementById('createPatientButton').addEventListener('click', async function(event) {
    event.preventDefault();

    // GET INPUT VALUES
    const firstName = document.getElementById('first-name-field').value.trim();
    const lastName = document.getElementById('last-name-field').value.trim();
    const dateOfBirthStr = document.getElementById('date-of-birth-field').value.trim();
    const address = document.getElementById('address-field').value.trim();
    const condition = document.getElementById('condition-field').value.trim();

    // VALIDATE INPUTS
    if (!firstName || !lastName || !dateOfBirthStr || !address || !condition) {
        alert('Please fill in all required fields.');
        return;
    }

    // CONVERT DATE OF BIRTH FROM STRING TO DATE OBJECT
    const [day, month, year] = dateOfBirthStr.split('-');
    const dateOfBirth = new Date(`${year}-${month}-${day}`);
    if (isNaN(dateOfBirth)) {
        alert('Invalid date of birth. Please use DD-MM-YYYY format.');
        return;
    }

    try {
        // GENERATE A UNIQUE NHS NUMBER
        const nhsNumber = await generateUniqueNHSNumber();

        // CREATE PATIENT DOCUMENT
        const patientData = {
            firstName,
            lastName,
            dateOfBirth: Timestamp.fromDate(dateOfBirth),
            address,
            patientId: nhsNumber
        };

        await addDoc(collection(db, 'patients'), patientData);

        // CREATE DISPATCH DOCUMENT
        const dispatchData = {
            date: Timestamp.now(),
            patientId: nhsNumber,
            status: 'pending',
            condition
        };

        await addDoc(collection(db, 'dispatches'), dispatchData);

        alert(`Patient and dispatch created successfully.\nAssigned NHS Number: ${nhsNumber}`);

        // RESET THE UI
        resetUI();
    } catch (error) {
        console.error('Error creating patient and dispatch:', error);
        alert('An error occurred while creating the patient and dispatch.');
    }
});

// ADD EVENT LISTENER FOR EXISTING PATIENT NEW DISPATCH BUTTON
document.getElementById('existingPatientNewDispatchButton').addEventListener('click', async function(event) {
    event.preventDefault();

    // GET THE CONDITION FROM: condition-field
    const condition = document.getElementById('condition-field').value.trim();

    // VALIDATE THAT CONDITION IS NOT EMPTY
    if (!condition) {
        alert('Please enter a condition.');
        return;
    }

    if (!foundPatientId) {
        alert('No patient selected.');
        return;
    }

    try {
        // CREATE DISPATCH DOCUMENT
        const dispatchData = {
            date: Timestamp.now(),
            patientId: foundPatientId,
            status: 'pending',
            condition
        };

        await addDoc(collection(db, 'dispatches'), dispatchData);

        alert('Dispatch created successfully.');

        // RESET THE UI
        resetUI();
    } catch (error) {
        console.error('Error creating dispatch:', error);
        alert('An error occurred while creating the dispatch.');
    }
});

// </script>