🚌 Bus Seat Reservation System

An 8086 Assembly Language bus seat reservation system designed to run in EMU8086.

📌 Overview

The system manages seat reservations for four buses. Each bus has 20 seats, and each destination has its own bus and ticket price.

Bus

Destination

Price

1

Adama

150 Birr

2

Hawassa

350 Birr

3

Bishoftu

120 Birr

4

Bahir Dar

600 Birr

✨ Features

View seats for each bus

Reserve a seat

Cancel a reservation

Check available/reserved seats

View booking summary

Automatically calculate fare

Generate booking IDs such as ADAMA-1

Validate seat numbers from 1–20

🔄 How It Works

Select Destination
       ↓
Identify Bus + Price
       ↓
Select Seat (1–20)
       ↓
Check Availability
       ↓
Confirm Reservation
       ↓
Save Reservation
       ↓
Display Booking Details

Each bus has a separate 20-seat array:

ADAMA_SEATS   DB 20 DUP(0)
HAWASSA_SEATS DB 20 DUP(0)
BISHOFTU_SEATS DB 20 DUP(0)
BAHIRDAR_SEATS DB 20 DUP(0)

0 = Available

1 = Reserved

🎫 Booking Example

If the user selects Adama and reserves seat 1:

Bus ID       : 1
Destination  : Adama
Seat Number  : 1
Booking ID   : ADAMA-1
Price        : 150 Birr

🖥️ Main Menu

1. View Bus Seats
2. Reserve Seat
3. Cancel Reservation
4. Available Seats
5. Booking Summary
6. Exit

🛠️ Technologies

8086 Assembly Language

EMU8086

DOS INT 21H

Arrays

Procedures

Loops and conditional jumps

📂 Project Structure

Bus-Seat-Reservation-System/
│
├── bus_reservation.asm
└── README.md

▶️ How to Run

Open EMU8086.

Open bus_reservation.asm.

Compile/assemble the program.

Run the program.

Use the menu to test reservations.

👥 Group Project

The project demonstrates practical use of:

Array-based seat management

Input validation

Procedures and modular programming

Reservation and cancellation logic

Destination/bus/price integration

Basic fare calculation

⚠️ Limitations

Reservations are stored only while the program is running. There is no database or permanent file storage.

🚀 Future Improvements

Passenger names and phone numbers

Date and departure time

Multiple buses per destination

Persistent booking storage

Search booking by ID

Printable ticket

Course Project — 8086 Assembly Language / EMU8086
