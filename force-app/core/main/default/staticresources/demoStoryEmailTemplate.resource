<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[[SUBJECT_LINE]] - Inbox - Gmail</title>
    <style>
        @font-face {
            font-family: 'Salesforce Sans';
            src: url('https://www.lightningdesignsystem.com/assets/fonts/webfonts/SalesforceSans-Regular.woff2') format('woff2');
            font-weight: 400;
            font-style: normal;
        }

        @font-face {
            font-family: 'Salesforce Sans';
            src: url('https://www.lightningdesignsystem.com/assets/fonts/webfonts/SalesforceSans-Bold.woff2') format('woff2');
            font-weight: 700;
            font-style: normal;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Salesforce Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: #f6f8fc;
            color: #202124;
            overflow: auto;
        }

        /* Header */
        .gmail-header {
            height: 64px;
            background-color: #fff;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            align-items: center;
            padding: 8px 16px;
            gap: 8px;
        }

        .menu-icon {
            width: 48px;
            height: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            border-radius: 50%;
            color: #5f6368;
        }

        .menu-icon:hover {
            background-color: #f1f3f4;
        }

        .menu-icon svg {
            width: 20px;
            height: 20px;
        }

        .gmail-logo {
            display: flex;
            align-items: center;
            margin-right: 24px;
            margin-left: 4px;
        }

        .gmail-logo img {
            height: 28px;
            width: auto;
        }

        .search-container {
            flex: 1;
            max-width: 720px;
        }

        .search-bar {
            display: flex;
            align-items: center;
            background-color: #f1f3f4;
            border-radius: 8px;
            padding: 0 16px;
            height: 48px;
            gap: 12px;
            transition: all 0.15s ease-in-out;
        }

        .search-bar:hover {
            background-color: #e9eaed;
            box-shadow: 0 1px 1px 0 rgba(65,69,73,.1), 0 1px 2px 0 rgba(65,69,73,.1);
        }

        .search-bar:focus-within {
            background-color: #fff;
            box-shadow: 0 1px 1px 0 rgba(65,69,73,.3), 0 2px 4px 1px rgba(65,69,73,.15);
        }

        .search-icon {
            width: 20px;
            height: 20px;
            color: #5f6368;
            flex-shrink: 0;
        }

        .search-bar input {
            flex: 1;
            border: none;
            background: none;
            outline: none;
            font-size: 16px;
            color: #202124;
            font-family: 'Google Sans', Roboto, Arial, sans-serif;
        }

        .search-bar input::placeholder {
            color: #5f6368;
        }

        .filter-icon {
            width: 20px;
            height: 20px;
            color: #5f6368;
            cursor: pointer;
            flex-shrink: 0;
        }

        .filter-icon:hover {
            opacity: 0.7;
        }

        .header-icons {
            display: flex;
            align-items: center;
            gap: 0;
            margin-left: auto;
        }

        .icon-btn {
            width: 48px;
            height: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            border-radius: 50%;
            color: #5f6368;
        }

        .icon-btn:hover {
            background-color: #f1f3f4;
        }

        .icon-btn svg {
            width: 20px;
            height: 20px;
            fill: #5f6368;
        }

        .toolbar-section .icon-btn {
            width: 36px;
            height: 36px;
        }

        .profile-section {
            display: flex;
            align-items: center;
            margin-left: 8px;
        }

        .profile-pic {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            overflow: hidden;
            cursor: pointer;
        }

        .profile-pic img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        /* Main Layout */
        .main-container {
            display: flex;
            height: auto;
            min-height: calc(100vh - 64px);
        }

        /* Sidebar */
        .sidebar {
            width: 256px;
            border-right: 1px solid #dadce0;
            background-color: #f6f8fc;
            display: flex;
            flex-direction: column;
            padding: 8px 0;
        }

        .compose-btn {
            margin: 8px 16px 16px 16px;
            background-color: #c2e7ff;
            border: none;
            border-radius: 28px;
            padding: 0 24px;
            height: 56px;
            display: flex;
            align-items: center;
            gap: 16px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            color: #001d35;
            box-shadow: 0 1px 2px 0 rgba(60,64,67,.3), 0 1px 3px 1px rgba(60,64,67,.15);
            transition: box-shadow 0.2s;
        }

        .compose-btn:hover {
            box-shadow: 0 1px 3px 0 rgba(60,64,67,.3), 0 4px 8px 3px rgba(60,64,67,.15);
        }

        .compose-btn svg {
            flex-shrink: 0;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 0 28px 0 24px;
            height: 32px;
            cursor: pointer;
            font-size: 14px;
            color: #202124;
            border-radius: 0 16px 16px 0;
            margin-right: 8px;
            position: relative;
        }

        .nav-item:hover {
            background-color: #f1f3f4;
        }

        .nav-item.active {
            background-color: #d3e3fd;
            font-weight: 500;
        }

        .nav-count {
            margin-left: auto;
            font-size: 12px;
            color: #202124;
        }

        .nav-icon {
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .nav-icon img {
            width: 20px;
            height: 20px;
        }

        .labels-section {
            margin-top: 12px;
            padding: 0 8px;
        }

        .labels-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 16px;
            height: 48px;
            font-size: 14px;
            color: #202124;
            font-weight: 500;
            cursor: pointer;
        }

        .labels-header .add-btn {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f1f3f4;
            color: #5f6368;
            font-size: 20px;
        }

        .label-tag {
            width: 16px;
            height: 16px;
            display: inline-block;
        }

        .label-tag svg {
            width: 16px;
            height: 16px;
        }

        /* Main Content */
        .content-area {
            flex: 1;
            display: flex;
            flex-direction: column;
            background-color: #fff;
        }

        .email-toolbar {
            display: flex;
            align-items: center;
            gap: 2px;
            padding: 8px 12px;
            border-bottom: 1px solid #dadce0;
            background-color: #fff;
        }

        .toolbar-section {
            display: flex;
            align-items: center;
            gap: 2px;
        }

        .toolbar-icons {
            display: flex;
            gap: 2px;
        }

        .checkbox-dropdown {
            display: flex;
            align-items: center;
            padding: 0 8px;
            height: 36px;
            border-radius: 4px;
            cursor: pointer;
        }

        .checkbox-dropdown:hover {
            background-color: #f1f3f4;
        }

        .pagination {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 4px;
            font-size: 12px;
            color: #5f6368;
        }

        .pagination-nav {
            display: flex;
            gap: 2px;
        }

        /* Email View */
        .email-view {
            padding: 10px 40px;
            font-family: 'Salesforce Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }

        .email-subject {
            padding-bottom: 8px;
            margin-bottom: 12px;
        }

        .subject-text {
            font-size: 24px;
            font-weight: 500;
            color: #202124;
        }


        /* Message Header */
        .message-header {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 8px 0;
            border-top: 1px solid #e8eaed;
        }

        .message-header:first-of-type {
            border-top: none;
        }

        .sender-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            overflow: hidden;
            background: #4285f4;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 16px;
            font-weight: 500;
            flex-shrink: 0;
        }
        /* Gentle entrance for the agent's reply — a soft rise + fade so an
           off-screen arrival registers as motion, without a loud highlight. */
        @keyframes msgArrive {
            from { opacity: 0; transform: translateY(10px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .message-card.just-arrived { animation: msgArrive 0.45s ease-out; }

        .sender-avatar.marketing-avatar {
            background: #ffffff;
            border: 1px solid #e8eaed;
        }

        .sender-avatar.marketing-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover !important;
        }

        .sender-avatar.agent {
            background: linear-gradient(135deg, #1976d2 0%, #0288d1 100%);
        }

        .sender-avatar.user {
            background: linear-gradient(135deg, #7b1fa2 0%, #c2185b 100%);
        }

        .sender-info {
            flex: 1;
        }

        .sender-name {
            font-size: 14px;
            font-weight: 500;
            color: #202124;
        }

        .sender-email {
            font-size: 12px;
            color: #5f6368;
            margin-left: 4px;
        }

        .recipient-info {
            font-size: 12px;
            color: #5f6368;
            margin-top: 2px;
        }

        .message-time {
            font-size: 12px;
            color: #5f6368;
            margin-left: auto;
        }

        .message-actions {
            display: flex;
            gap: 4px;
        }

        .message-actions .icon-btn {
            width: 32px;
            height: 32px;
        }

        /* Message Body */
        .message-card {
            padding: 8px 0;
            margin: 0;
            background-color: transparent;
            border: none;
        }

        .message-card.first-message {
            border: 1px solid #e8eaed;
            border-radius: 8px;
            padding: 12px;
            margin: 8px 0;
            background-color: #fff;
        }

        /* Header logo: ensure visible inside flex + srcdoc preview */
        .message-card.first-message > div {
            min-width: 0;
        }

        .email-header-logo img {
            max-width: 100% !important;
            height: auto !important;
            display: block !important;
            margin-left: auto !important;
            margin-right: auto !important;
            vertical-align: middle;
        }

        .message-icon {
            text-align: center;
            margin-bottom: 24px;
            font-size: 48px;
        }

        .message-body {
            font-size: 15px;
            line-height: 1.6;
            color: #202124;
        }

        .message-body p {
            margin-bottom: 12px;
        }

        .message-body ul {
            margin: 12px 0 12px 24px;
        }

        .message-body li {
            margin-bottom: 6px;
        }

        .message-body strong {
            font-weight: 500;
        }

        .cta-button {
            background-color: #1a73e8;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 10px 24px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            margin-top: 8px;
        }

        .cta-button:hover {
            background-color: #1765cc;
            box-shadow: 0 1px 2px 0 rgba(66,133,244,.3), 0 1px 3px 1px rgba(66,133,244,.15);
        }

        .message-footer {
            margin-top: 20px;
            font-size: 13px;
            color: #5f6368;
            line-height: 1.5;
        }

        /* Reply Buttons */
        .reply-buttons {
            display: flex;
            gap: 16px;
            padding: 24px 0;
        }

        .reply-btn, .forward-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 24px;
            border: 1px solid #5f6368;
            border-radius: 24px;
            background-color: #fff;
            font-size: 14px;
            font-weight: 500;
            color: #202124;
            cursor: pointer;
            transition: all 0.2s;
        }

        .reply-btn:hover, .forward-btn:hover {
            background-color: #f8f9fa;
            box-shadow: 0 1px 2px 0 rgba(60,64,67,.3), 0 1px 3px 1px rgba(60,64,67,.15);
        }

        .reply-btn svg, .forward-btn svg {
            width: 20px;
            height: 20px;
            fill: #5f6368;
        }

        /* Reply Compose */
        .reply-compose {
            display: none;
            border: 1px solid #dadce0;
            border-radius: 8px;
            margin: 16px 0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            background-color: #fff;
        }

        .reply-compose.active {
            display: block;
        }

        .compose-header {
            display: flex;
            align-items: center;
            padding: 12px 16px;
            border-bottom: 1px solid #e8eaed;
            gap: 12px;
        }

        .compose-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            overflow: hidden;
            flex-shrink: 0;
        }

        .compose-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .compose-recipient {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 1;
        }

        .compose-recipient svg {
            width: 20px;
            height: 20px;
            fill: #5f6368;
        }

        .recipient-name {
            font-size: 14px;
            color: #202124;
            font-weight: 400;
        }

        .compose-popout {
            margin-left: auto;
            cursor: pointer;
            padding: 8px;
            border-radius: 4px;
        }

        .compose-popout:hover {
            background-color: #f1f3f4;
        }

        .compose-popout svg {
            width: 18px;
            height: 18px;
            fill: #5f6368;
        }

        .reply-textarea {
            width: 100%;
            min-height: 160px;
            border: none;
            padding: 16px;
            font-family: Arial, sans-serif;
            font-size: 14px;
            color: #202124;
            resize: vertical;
            outline: none;
            line-height: 1.5;
        }

        .compose-signature {
            padding: 0 16px 16px 16px;
            color: #5f6368;
            font-size: 13px;
            line-height: 1.6;
            border-bottom: 1px solid #e8eaed;
        }

        .signature-divider {
            margin-bottom: 8px;
            color: #dadce0;
        }

        .compose-toolbar {
            padding: 8px 12px;
            background-color: #f8f9fa;
            display: flex;
            align-items: center;
            gap: 8px;
            border-bottom: 1px solid #e8eaed;
        }

        .toolbar-group {
            display: flex;
            gap: 4px;
            align-items: center;
        }

        .toolbar-btn {
            padding: 6px;
            border-radius: 4px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #5f6368;
        }

        .toolbar-btn:hover {
            background-color: #e8eaed;
        }

        .toolbar-separator {
            width: 1px;
            height: 20px;
            background-color: #dadce0;
            margin: 0 4px;
        }

        .compose-actions {
            padding: 12px 16px;
            background-color: #fff;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .send-btn-group {
            display: flex;
        }

        .send-btn {
            background-color: #1a73e8;
            color: #fff;
            border: none;
            border-radius: 4px 0 0 4px;
            padding: 10px 24px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
        }

        .send-btn:hover {
            background-color: #1765cc;
            box-shadow: 0 1px 2px 0 rgba(60,64,67,.3), 0 1px 3px 1px rgba(60,64,67,.15);
        }

        .send-btn:disabled {
            background-color: #dadce0;
            color: #5f6368;
            cursor: not-allowed;
        }

        .send-dropdown {
            background-color: #1a73e8;
            color: #fff;
            border: none;
            border-left: 1px solid rgba(255,255,255,0.2);
            border-radius: 0 4px 4px 0;
            padding: 10px 8px;
            cursor: pointer;
            display: flex;
            align-items: center;
        }

        .send-dropdown:hover {
            background-color: #1765cc;
        }

        .send-dropdown svg {
            width: 16px;
            height: 16px;
            fill: #fff;
        }

        .compose-bottom-icons {
            display: flex;
            gap: 4px;
            flex: 1;
        }

        .compose-bottom-icons .toolbar-btn {
            color: #5f6368;
        }

        .compose-delete {
            margin-left: auto;
            padding: 8px;
            cursor: pointer;
            border-radius: 4px;
        }

        .compose-delete:hover {
            background-color: #f1f3f4;
        }

        .compose-delete svg {
            width: 20px;
            height: 20px;
            fill: #5f6368;
        }


        .badge {
            background-color: #e8f0fe;
            color: #1967d2;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 500;
            margin-left: 8px;
        }



        /* Icons */
        .icon {
            width: 20px;
            height: 20px;
        }
    </style>
</head>
<body>
    <div class="gmail-header">
        <div class="menu-icon">
            <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"/>
            </svg>
        </div>
        <div class="gmail-logo">
            <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAANoAAABQCAMAAABI6JtXAAAB11BMVEUAAAC/ICDEIh7FIh/FIh/EIh/FIx/HIx77uwT7vAT7vAP7vAT7vAT8vAP/vwDHIyDGIh6/ICD/vwD7vQT7vAT8vAX3vwD6vAPFIh/FIh/GIh76vAXrRDXfQDDrQjX/twjCIx3qQzXqQzXnSDD8vgNAQEBASEhFRUVESEjCIB3qQzXoQjftQzXrQzT6vQNDR0VFR0ZER0ZER0ZERkZER0VGRkZCR0RERkZERkVER0ZER0ZER0ZESERFR0ZISEhDR0dDR0ZDR0ZER0ZDSEZERkVER0ZESEZASEBCSEVDR0VDR0WCUoq0LjriuQ51rThERkVDRkZChfJSedmcQWLJtxhBqU4yp1JFRUVARUVChfSEU4qLsTA0qFNbcsxmrT9DRkRGRkZFR0ZER0dDR0dESEhDR0VAQEBFR0dER0ZASEhER0VER0VDR0VERkVDR0VER0brQzTqQzRHR0dESERDR0bpRDToRDRER0dCR0TqQDXpQjXnRDTnQDjfQEBERkZERkZISEhFRUVFSEVDRkNFRUVDRkRCSEVFR0VFR0VFSEhFSEhARUVDRkZER0dFR0ZER0ZDR0VFSEVDg/I0p1RAgO9BhfQwp1BAhPE0p1RAhfJBhPQ0p1IzqVO/3uLxAAAAnXRSTlMAIJDf/++/X0C/7//PnyBfjxAQj+9fIN/P73BvjxCPIFD/3yBPECAwQGDvcG/vYJ/f/89/v19wgO8Bj/5AASCer9/vXwGvgCBgAZBg//9gz1Bg/////2BgMP///////6BQ3nCfQXARn84hAb5v7o/ur79PQd6AcE9xMN9AIBABoCExYFBhAWGeb2BhMa9v3f2eX1BAEO8gcIBgz89fZda5bQAABHNJREFUeAHs0YMBAwEQBMB742LjrTj9dxfb5k4FC4KHAgAAAAAAABBESVZUjS6kGyan0hn6AllFnsnl6QKFIs+Uyl/wmbwkCXRWpcpLOn26mrxSb9AZTZNXjG85bc6y6QTb4U0ufTZvq5ofhHRUGPi8KaJLxEmrndA7dLar+d0eHdEf+NvVhmNm7EK5bSCKwvB9GckatK6tVEpWYeYyMzOGGcrcN653naNIE8FK2cA/1Bpm/I2OoC1mOXWXVY26Q8Zqul4Hyc74vm/p0lphlAhjlO+VolnNgGO5HWSkzi5mFiERdbvMwi5BwygRxliW5riMgOsxQmNZbyVacpQYY1lak9sFXr3P62fVwKAB2pDawnA1WnKUGGMZGmTByCip7LG2rkaHbnxCDnKwmDY5lUbDKDHGNNr0TKFsxKL9RuQLZKKRWe8sFdPOnb+QQsMoMcYU2sVLlymzKxLWf5UShQFkRiqmXbt2PY2GUWKMoKEbN29m03pcKbMpGYF6fLRrt6ZSaGqUGCOKxnj7Zh7tDreqDjFIuxaNEgSMEmNE0Rhv5tF6WP+0smqOY6X/DdkOXqxAwyhByywaYy7tipwj5dbj+/5dop4JdSXfe7hwPJbd6yAkXwtY1mj2RH7f9+/r0jDKYhrGmEuTv/AB5fZQ3XUf8V6iSfT4CaOnVuzJA7mSI3sm+bo0jLKYhjHm0rhVWEx74HOUuP/c4/1ekAqvwV+BhlEW0zDGPFqNW1ExLZBT9F9O9KsHlS75ysRLv08pQhyz9md8r+2vQMMoi2gYYy7NkesppMlehbiZq163f7mkvog+9MLef/WNVZ6GUb7Nl73DGEHLvIp4FMtNdO89frUIsTvIVB/kWwox1s9zhDMswGErR0M0nydboJuVaJxI3Aetl2IYnrNiz79ikVShTWgJ36hIo+WVLNjKKunTGtk09vdoooYPPMZBiw6iuEIo/qGnh6HR2tuMMa4TaBqXkYGMQQYx2htCnVinamMzRnOa6sbWGO7YgqgiTTafPkbSpVncyqbU8Ksl7UWSZqfQtjyOcg3QkqPEGPVpJH/Elcy7uQi1adsBxzJBS44SY9SnTeA6knpAhaVL21KyYGJnd3dnot8MLTFKjFGfFmY+jnzEpUCH9umOurrgwvnZEA2jxBi1aZgdNzKmKgZ1aY9xg8CHDNEwSoxRn4bD1kUH8kHQoj1MvEoPTdAwSoyxNI3Ug2Az9T9MRqgUjZCapwEaRokxlqVZ6qSv9yRe61LPHKRN28Y1B0fcCA2jXKdqNLL78R/GyHGVzCYqda59iWRGaag8DTYO6l+dmu18mwgYMk0anprv3bXI+u7x6aGRPcsHempTCZp62I8SI6eGpv5JkigYsagUjX7s28TrzlNEI3tsNh2mSyP7pxAK9uoXdQohfisa/tB9T4g/x0+Dbteve331iZ1Rqpb9sv7i7+t/FhVnnnZq+9/+fNAAAMMwEDR/7e4FthysFSl/DK74tarYWrdrQ8FNt7YU3j5O7T4BAAAAAIAUPnsb6R/sjg4HAAAAAElFTkSuQmCC" alt="Gmail">
        </div>
        <div class="search-container">
            <div class="search-bar">
                <svg class="search-icon" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M20.49 19l-5.73-5.73C15.53 12.2 16 10.91 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.41 0 2.7-.47 3.77-1.24L19 20.49 20.49 19zM5 9.5C5 7.01 7.01 5 9.5 5S14 7.01 14 9.5 11.99 14 9.5 14 5 11.99 5 9.5z"/>
                </svg>
                <input type="text" placeholder="Search mail">
                <svg class="filter-icon" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M3 17v2h6v-2H3zM3 5v2h10V5H3zm10 16v-2h8v-2h-8v-2h-2v6h2zM7 9v2H3v2h4v2h2V9H7zm14 4v-2H11v2h10zm-6-4h2V7h4V5h-4V3h-2v6z"/>
                </svg>
            </div>
        </div>
        <div class="header-icons">
            <div class="icon-btn">
                <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-.9-2-2-2s-2 .9-2 2H8c0-2.21 1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z"/>
                </svg>
            </div>
            <div class="icon-btn">
                <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.05.3-.09.63-.09.94s.02.64.07.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z"/>
                </svg>
            </div>
            <div class="icon-btn">
                <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M6 10c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm12 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm-6 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/>
                </svg>
            </div>
            <div class="profile-section">
                <div class="profile-pic">
                    <img src="[[CUSTOMER_AVATAR_URL]]" alt="Profile" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 100 100\'%3E%3Ccircle cx=\'50\' cy=\'50\' r=\'50\' fill=\'%23667eea\'/%3E%3Ctext x=\'50\' y=\'50\' text-anchor=\'middle\' dy=\'.3em\' fill=\'white\' font-size=\'35\' font-family=\'Arial\'%3E[[CUSTOMER_INITIALS]]%3C/text%3E%3C/svg%3E';">
                </div>
            </div>
        </div>
    </div>

    <div class="main-container">
        <div class="sidebar">
            <button class="compose-btn">
                <svg width="24" height="24" viewBox="0 0 24 24">
                    <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z" fill="#041e49"/>
                </svg>
                Compose
            </button>

            <div class="nav-item active">
                <div class="nav-icon">
                    <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAo0lEQVR4Ae3YAQaAQBAF0GX3AB2g5iwBmi5VN6gbdoO6QdWGFSp81dr8zycts88AZRiG+XOc1I0VnZzo8kb32YV2IE477GKgCNLhm0M6IcAwwODB7yCQQAIJJJBAAtMB3tVkZYbP+QDo8qo0F/Fn0YFWdDjbon/nz2IDAzJscoP554CLCsSbPpBAAhP47Kza74D434XePrvJ+VgrOgK4pMIwzAru8JVaXEjy0gAAAABJRU5ErkJggg==" alt="Inbox">
                </div>
                <span>Inbox</span>
                <span class="nav-count">225</span>
            </div>
            <div class="nav-item">
                <div class="nav-icon">
                    <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAB7UlEQVR4Ae1Wi03DMBBlBEZghI5g1ffTl27QbEA3oBvABKQblA06QkboCNkA0JNk6p4qkhASGSknnZSPfT77vXvnu8UWW2yxi5FZIKNQbIJR6BCV6yKTM7MHUvkklTaEcF8evCovSBBOIvviEmSVM5JLp1hWcswVEstdVR/LgVe48QmS8qkcackTE27TMySnCGlJCUXVOiq/Xt65LkJakge8GwU8zy45WJyZVyKyYbOKlZ/As1ucu/4uR4zFPNABMUYlTSLPgAaLQDoSp7o8mmxTDHeK3j1fG6yFjZDqrjNB7C5iMAL09Khy9nH6bixHYNDJksn+9o75hBNGMaBjsHEVmFd+Pr7hH8ZgLDaNudiMj4v/bvrvkgTkgG+UJLmTxRojZSRufFBwZXAcFJVDI4ps/qyCPTQopiGF5znraDFJkvBjF7FZtXZzGsQal03/Cm8H3XJMDogx583lvQe8360Qc2ftvb5Y0PrMwbdW2uW9et6rlVFI0KMQUJm+gMC3XKbmvBy0SdtynuXJiMjWd5VJOQhNzKUiXQo6/IhTn4WHaEk/N37drY0rL0e+rc3CP78ooLvSzKx6nTeTaeCtGwgKpa+4T8pDFIOHs+9cDzs2NRn/PJxd5mBH2/uYhIe4143YuYNd3+4WW+yf2BfK3SI5uCgSUAAAAABJRU5ErkJggg==" alt="Starred">
                </div>
                <span>Starred</span>
            </div>
            <div class="nav-item">
                <div class="nav-icon">
                    <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAMAAAC7IEhfAAAAe1BMVEUAAABAQEBFSEhDR0VER0ZERkVER0ZGRkZISEhDR0VER0ZFR0ZER0VDR0VARUVESERFRUVASEhDRkZER0ZCSEVDR0ZERkZDSEZDRkRDR0dFRUVER0dCR0RERkVESEhERkZESEZDR0ZDRkZERkVFR0VER0ZDR0VDR0dFSEWPuhUwAAAAKXRSTlMAEGCfz+//XyCQj9+/bzBAMCCg72DfgF+gn2BwcM9AoIDeX+5v/o+eYLzI8ccAAAEqSURBVHgB1ZRVYsMwEAWf6mhCZiiH8f4XLNfRGg6Q+TLMglD3h3uIJh78JJrONM5s7rkRjalugYWFG0y3BIiT1EkuS2KA5UDS3ANxppaiBKp8KJ+vZag9VJ2cbglNqh8e4fEvaQNL2+cCfKGuqMLDwhQGntQXVQNh8Wd40ZCoGCKbsBgWM6huXb5CLCuGKV/Dym9j4nvY1QqyMTGHSfviwY2JDqr2BZARw5UDRsSiMSYwUtqapvQKco2Y63AwGzM91jTTYyfcmnGwC+Q8ZD3Tp5JmmP7nvZQqVmlvu0gFtsuwKQoFzNvmDTMPW4W4BpY9M1/Czg0Ms1N972FXSH3TXA7rGDik0qBJfFw7yeXHGIJ8li2W09lpmKLkhr8UGqeoy5UHv4quTnfHJw68EvezWz+WAAAAAElFTkSuQmCC" alt="Snoozed">
                </div>
                <span>Snoozed</span>
            </div>
            <div class="nav-item">
                <div class="nav-icon">
                    <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAA50lEQVR4Ae2UDQmCMRBAjWAEIxjhcLvbtdAGRtAINtAGRjDCF8EIRlBP/oeOvwd+wD0YYzDG2xtskXwnSZKkNpvMbCsiy7kKPj/D9FGanlV1PUvBbsBVeUG+KiFYzC4x81UhwViL+2rjuivN7nBVQLCjehWwKi8YwFV5wb9X7Q/Xpnt3X3XbgKqA4EAWq8oIDmSpqrCg3qrbUVyGglEoLhL7B4KnKA4IdlIDqruUZtcQ+HVWeYsDT9xLjWtVs0M1nYBa5DdD1wIE+VqQIF8LEORrgYJ8LVgQqMUD1+KBa/HMo1aSJEnyAucp7kGaONODAAAAAElFTkSuQmCC" alt="Sent" style="width: 20px; height: 20px;">
                </div>
                <span>Sent</span>
            </div>
            <div class="nav-item">
                <div class="nav-icon">
                    <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAhElEQVR4Ae3YwQ2AIAxAUZxNKGM5Ak4qG6jcqseKmJr8nzTc4KVHwh8iillKlFTbeZhHZBmPs8O+Q+rmnCKvjwRDdqQHoCIdAxXpGKhIx0BFegTqAHwSQIAAAQIECBAgQIAAO+6b3gXavz4sU7uBc07rKGC7u/T6FNm3yf02kjbFEfnuBDmMOjQnG4eeAAAAAElFTkSuQmCC" alt="Drafts">
                </div>
                <span>Drafts</span>
                <span class="nav-count">18</span>
            </div>
            <div class="nav-item">
                <div class="nav-icon">
                    <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABW0lEQVR4Ae2XIXDDMAxFw9E4GkflyFdLkuE4WTlZOdk4GicdJysn4WThZOXIHHX30Xo6Fyitegb+d0Kt5WdH0k+moaGhIb9KKc+kPJPKQiLv3cGxyolUzv+h++7gTBxXJWTmDR5DVj6IyCs2CIA7Z9XDOjjh2kgI4E8qJd0HTk5pzcGz5JfcTmqCZ1Z+w4Hi4RraFt41QRsBkMtyiIMzQiI8ViR2hXCNhGuDiny5IOPh2qAkvDweLq4+EdXCdQeaUnrqyiFsMPOuWzgEJkFvcDZqF3Cox2szMKhR/PZFIh/mt+hXK7+3tjub5wiQBYlR5B5vpUKpVYd3GTdbpT02vdUhcDD7f4AHDWG/fQEmetwYUL+3ZpVvA7lMEULtYHx4bwKHwLqH2J4ZH0fPunjbM7eIjnavMx9K0bdYb7j9nwmKvEU0ibeWssovItzy0NVrNknMm3C4oaGhjvQHOQ9aFOZ+r+8AAAAASUVORK5CYII=" alt="Travel">
                </div>
                <span>Travel</span>
                <span class="nav-count">9</span>
            </div>
            <div class="nav-item">
                <div class="nav-icon">
                    <svg viewBox="0 0 20 20" fill="#5f6368">
                        <path d="M6 8l4 4 4-4z"/>
                    </svg>
                </div>
                <span>More</span>
            </div>

            <div class="labels-section">
                <div class="labels-header">
                    <span>Labels</span>
                    <div class="add-btn">+</div>
                </div>
                <div class="nav-item">
                    <div class="label-tag">
                        <svg viewBox="0 0 16 16">
                            <path d="M3.5 2A1.5 1.5 0 0 0 2 3.5v9A1.5 1.5 0 0 0 3.5 14h9a1.5 1.5 0 0 0 1.5-1.5v-9A1.5 1.5 0 0 0 12.5 2h-9z" fill="#5f6368"/>
                        </svg>
                    </div>
                    <span>Meetings</span>
                </div>
                <div class="nav-item">
                    <div class="label-tag">
                        <svg viewBox="0 0 16 16">
                            <path d="M3.5 2A1.5 1.5 0 0 0 2 3.5v9A1.5 1.5 0 0 0 3.5 14h9a1.5 1.5 0 0 0 1.5-1.5v-9A1.5 1.5 0 0 0 12.5 2h-9z" fill="#d93025"/>
                        </svg>
                    </div>
                    <span>Important</span>
                </div>
                <div class="nav-item">
                    <div class="label-tag">
                        <svg viewBox="0 0 16 16">
                            <path d="M3.5 2A1.5 1.5 0 0 0 2 3.5v9A1.5 1.5 0 0 0 3.5 14h9a1.5 1.5 0 0 0 1.5-1.5v-9A1.5 1.5 0 0 0 12.5 2h-9z" fill="#1967d2"/>
                        </svg>
                    </div>
                    <span>Work</span>
                </div>
                <div class="nav-item">
                    <div class="label-tag">
                        <svg viewBox="0 0 16 16">
                            <path d="M3.5 2A1.5 1.5 0 0 0 2 3.5v9A1.5 1.5 0 0 0 3.5 14h9a1.5 1.5 0 0 0 1.5-1.5v-9A1.5 1.5 0 0 0 12.5 2h-9z" fill="#188038"/>
                        </svg>
                    </div>
                    <span>Personal</span>
                </div>
                <div class="nav-item">
                    <div class="label-tag">
                        <svg viewBox="0 0 16 16">
                            <path d="M3.5 2A1.5 1.5 0 0 0 2 3.5v9A1.5 1.5 0 0 0 3.5 14h9a1.5 1.5 0 0 0 1.5-1.5v-9A1.5 1.5 0 0 0 12.5 2h-9z" fill="#e37400"/>
                        </svg>
                    </div>
                    <span>Follow-up</span>
                </div>
            </div>
        </div>

        <div class="content-area">
            <div class="email-toolbar">
                <div class="toolbar-section">
                    <div class="checkbox-dropdown">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="#5f6368">
                            <path d="M19 5v14H5V5h14m0-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z"/>
                        </svg>
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="#5f6368">
                            <path d="M7 10l5 5 5-5z"/>
                        </svg>
                    </div>
                    <div class="icon-btn">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
                        </svg>
                    </div>
                    <div class="icon-btn">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/>
                        </svg>
                    </div>
                </div>
                <div class="pagination">
                    <span>1-25 of 226</span>
                    <div class="pagination-nav">
                        <div class="icon-btn">
                            <svg viewBox="0 0 24 24" fill="currentColor">
                                <path d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/>
                            </svg>
                        </div>
                        <div class="icon-btn">
                            <svg viewBox="0 0 24 24" fill="currentColor">
                                <path d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z"/>
                            </svg>
                        </div>
                    </div>
                    <div class="icon-btn">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/>
                        </svg>
                    </div>
                </div>
            </div>

            <div class="email-view">
                <div class="email-subject">
                    <div class="subject-text">[[SUBJECT_LINE]]</div>
                </div>

                <div id="thread-container">
                    <div class="message-header">
                        <div class="sender-avatar marketing-avatar" id="marketing-sender-avatar">
                            <script>
                                (function() {
                                    const avatarUrl = '[[MARKETING_AVATAR_URL]]';
                                    const initials = '[[MARKETING_INITIALS]]';
                                    const avatarDiv = document.getElementById('marketing-sender-avatar');
                                    if (avatarUrl && avatarUrl.trim() !== '') {
                                        avatarDiv.style.backgroundColor = 'transparent';
                                        avatarDiv.innerHTML = '<img src="' + avatarUrl + '" alt="[[BRAND_NAME]]" style="width: 100%; height: 100%; object-fit: cover;">';
                                    } else {
                                        avatarDiv.innerHTML = initials;
                                        avatarDiv.style.background = 'linear-gradient(135deg, #1976d2 0%, #0288d1 100%)';
                                    }
                                })();
                            </script>
                        </div>
                        <div class="sender-info">
                            <div>
                                <span class="sender-name">[[BRAND_NAME]]</span>
                                <span class="sender-email">&lt;marketing@[[BRAND_DOMAIN]]&gt;</span>
                            </div>
                            <div class="recipient-info">to [[CUSTOMER_FIRST_NAME]] ▼</div>
                        </div>
                        <div class="message-time">11:06 AM (1 hour ago)</div>
                        <div class="message-actions">
                            <div class="icon-btn">
                                <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAB7UlEQVR4Ae1Wi03DMBBlBEZghI5g1ffTl27QbEA3oBvABKQblA06QkboCNkA0JNk6p4qkhASGSknnZSPfT77vXvnu8UWW2yxi5FZIKNQbIJR6BCV6yKTM7MHUvkklTaEcF8evCovSBBOIvviEmSVM5JLp1hWcswVEstdVR/LgVe48QmS8qkcackTE27TMySnCGlJCUXVOiq/Xt65LkJakge8GwU8zy45WJyZVyKyYbOKlZ/As1ucu/4uR4zFPNABMUYlTSLPgAaLQDoSp7o8mmxTDHeK3j1fG6yFjZDqrjNB7C5iMAL09Khy9nH6bixHYNDJksn+9o75hBNGMaBjsHEVmFd+Pr7hH8ZgLDaNudiMj4v/bvrvkgTkgG+UJLmTxRojZSRufFBwZXAcFJVDI4ps/qyCPTQopiGF5znraDFJkvBjF7FZtXZzGsQal03/Cm8H3XJMDogx583lvQe8360Qc2ftvb5Y0PrMwbdW2uW9et6rlVFI0KMQUJm+gMC3XKbmvBy0SdtynuXJiMjWd5VJOQhNzKUiXQo6/IhTn4WHaEk/N37drY0rL0e+rc3CP78ooLvSzKx6nTeTaeCtGwgKpa+4T8pDFIOHs+9cDzs2NRn/PJxd5mBH2/uYhIe4143YuYNd3+4WW+yf2BfK3SI5uCgSUAAAAABJRU5ErkJggg==" alt="Star" style="width: 20px; height: 20px;">
                            </div>
                            <div class="icon-btn">
                                <svg viewBox="0 0 24 24" fill="#5f6368" style="width: 20px; height: 20px;">
                                    <path d="M10 9V5l-7 7 7 7v-4.1c5 0 8.5 1.6 11 5.1-1-5-4-10-11-11z"/>
                                </svg>
                            </div>
                            <div class="icon-btn">
                                <svg viewBox="0 0 24 24" fill="#5f6368" style="width: 20px; height: 20px;">
                                    <path d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/>
                                </svg>
                            </div>
                        </div>
                    </div>

                    <div class="message-card first-message" style="display: flex; justify-content: center;">
                        <div style="max-width: 600px; width: 100%; min-width: 0;">
                            <table style="background-color:#ffffff; width: 600px; max-width: 600px;" role="presentation" cellpadding="0" cellspacing="0" align="center">
                                <tbody>
                                    <tr>
                                        <td style="padding: 0;">
                                            <!-- Main brand logo (above headline banner; [[LOGO_BG_COLOR]] for PNG transparency vs email white) -->
                                            <table class="email-header-logo" cellpadding="0" cellspacing="0" border="0" width="100%" role="presentation" style="background-color: [[LOGO_BG_COLOR]];">
                                                <tr>
                                                    <td style="padding: 20px 0; text-align: center;">
                                                        <img src="[[LOGO_URL]]" alt="[[BRAND_NAME]]" loading="eager" referrerpolicy="no-referrer" style="width: [[LOGO_WIDTH]]; max-width: 100%; height: auto; display: block; margin: 0 auto;">
                                                    </td>
                                                </tr>
                                            </table>

                                            <table cellpadding="0" cellspacing="0" border="0" width="100%" role="presentation" style="background-color: [[PRIMARY_COLOR]];">
                                                <tr>
                                                    <td style="padding: 20px; text-align: center;">
                                                        <h1 style="color: [[HEADLINE_TEXT_COLOR]]; font-size: 32px; margin: 0; font-weight: bold;">[[HEADLINE]]</h1>
                                                    </td>
                                                </tr>
                                            </table>

                                            <table cellpadding="0" cellspacing="0" border="0" width="100%" role="presentation">
                                                <tr>
                                                    <td style="padding: 0; text-align: center;">
                                                        <img src="[[HERO_IMAGE_URL]]" alt="" style="max-width: 100%; width: 100%; height: auto; display: block;">
                                                    </td>
                                                </tr>
                                            </table>



                                            <table cellpadding="0" cellspacing="0" border="0" width="100%" role="presentation" style="background-color: [[FEATURE_SECTION_COLOR]];">
                                                <tr>
                                                    <td style="padding: 20px;">
                                                        <table cellpadding="0" cellspacing="0" border="0" width="100%" role="presentation">
                                                            <tr>
                                                                <td style="width: 50%; padding: 10px; color: [[FEATURE_COLUMN_TEXT_COLOR]]; font-size: 14px; line-height: 1.5; vertical-align: top;">[[FEATURE_COLUMN_1]]</td>
                                                                <td style="width: 50%; padding: 10px; color: [[FEATURE_COLUMN_TEXT_COLOR]]; font-size: 14px; line-height: 1.5; vertical-align: top;">[[FEATURE_COLUMN_2]]</td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>

                                            <table cellpadding="0" cellspacing="0" border="0" width="100%" role="presentation">
                                                <tr>
                                                    <td style="padding: 30px 20px;">
                                                        <h3 style="text-align: center; font-size: 20px; font-weight: bold; margin: 0 0 20px 0; color: #000000;">[[SUB_HEADLINE]]</h3>


                                                        <div style="font-size: 14px; line-height: 1.6; color: #393939;">[[BODY_PARAGRAPH]]</div>

                                                        <div style="[[BULLETS_DISPLAY]]">
                                                        <p style="font-size: 14px; line-height: 1.6; color: #393939; margin: 0 0 12px 0;">- [[BULLET_1]]</p>

                                                        <p style="font-size: 14px; line-height: 1.6; color: #393939; margin: 0 0 12px 0;">- [[BULLET_2]]</p>

                                                        <p style="font-size: 14px; line-height: 1.6; color: #393939; margin: 0 0 16px 0;">- [[BULLET_3]]</p>
                                                        </div>

                                                        <p style="font-size: 14px; line-height: 1.6; color: #393939; margin: 0 0 16px 0;">💬 <strong>[[REPLY_PROMPT_HEADLINE]]</strong><br>[[REPLY_PROMPT_BODY]]</p>

                                                        <p style="font-size: 14px; line-height: 1.6; color: #393939; margin: 0 0 24px 0;">Best,<br>[[BRAND_NAME]]</p>

                                                        <div style="text-align: center; margin: 24px 0;">
                                                            <a href="#" onclick="document.getElementById('show-reply').click(); setTimeout(() => { document.getElementById('reply-compose').scrollIntoView({ behavior: 'smooth', block: 'center' }); }, 100); return false;" style="display: inline-block; background-color: [[CTA_BUTTON_COLOR]]; color: #ffffff; text-decoration: none; padding: 12px 32px; border-radius: 25px; font-size: 16px; font-weight: 500;">[[CTA_BUTTON_TEXT]]</a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>

                                            <table cellpadding="0" cellspacing="0" border="0" width="100%" role="presentation">
                                                <tr>
                                                    <td style="padding: 20px; text-align: center;">
                                                        <p style="font-size: 12px; color: #666666; margin: 0 0 5px 0;">© [[BRAND_NAME]]. All rights reserved.</p>
                                                        <p style="font-size: 11px; color: #666666; margin: 0;">Built for Salesforce Solution Engineers</p>
                                                    </td>
                                                </tr>
                                            </table>

                                            <table cellpadding="0" cellspacing="0" border="0" width="100%" role="presentation" style="background-color: [[PRIMARY_COLOR]];">
                                                <tr>
                                                    <td style="padding: 24px 20px; text-align: center; vertical-align: middle;">
                                                        <table cellpadding="0" cellspacing="0" border="0" align="center" role="presentation" style="margin: 0 auto;">
                                                            <tr>
                                                                <td style="padding: 0 12px; vertical-align: middle;">
                                                                    <img src="https://storm-9a196766da4ee3.cdn.salesforce-experience.com/cms/delivery/media/MCR23Z32BRKZBC5GUZSOGAAV7KZU?channelId=0apKh000000tUrbIAE&oid=00DKh000002NAZG" alt="Facebook" style="width: 32px; height: 32px; display: block;">
                                                                </td>
                                                                <td style="padding: 0 12px; vertical-align: middle;">
                                                                    <img src="https://storm-9a196766da4ee3.cdn.salesforce-experience.com/cms/delivery/media/MCQOCZTPA7WZHURJ5DTYPB6QHSXU?channelId=0apKh000000tUrbIAE&oid=00DKh000002NAZG" alt="X" style="width: 32px; height: 32px; display: block;">
                                                                </td>
                                                                <td style="padding: 0 12px; vertical-align: middle;">
                                                                    <img src="https://storm-9a196766da4ee3.cdn.salesforce-experience.com/cms/delivery/media/MC6DTTCFKO7JAFFJ4JYFI3FKT7VE?channelId=0apKh000000tUrbIAE&oid=00DKh000002NAZG" alt="Instagram" style="width: 32px; height: 32px; display: block;">
                                                                </td>
                                                                <td style="padding: 0 12px; vertical-align: middle;">
                                                                    <img src="https://storm-9a196766da4ee3.cdn.salesforce-experience.com/cms/delivery/media/MCP7C5APQ7NRBM5IX6SO776GQNVA?channelId=0apKh000000tUrbIAE&oid=00DKh000002NAZG" alt="YouTube" style="width: 32px; height: 32px; display: block;">
                                                                </td>
                                                                <td style="padding: 0 12px; vertical-align: middle;">
                                                                    <img src="https://storm-9a196766da4ee3.cdn.salesforce-experience.com/cms/delivery/media/MCFMU7W54IKNFDTMPDPD65VFBVWE?channelId=0apKh000000tUrbIAE&oid=00DKh000002NAZG" alt="Threads" style="width: 32px; height: 32px; display: block;">
                                                                </td>
                                                                <td style="padding: 0 12px; vertical-align: middle;">
                                                                    <img src="https://storm-9a196766da4ee3.cdn.salesforce-experience.com/cms/delivery/media/MCKPCLK2XS6FEYNIOHDVQTNJ5E4A?channelId=0apKh000000tUrbIAE&oid=00DKh000002NAZG" alt="WhatsApp" style="width: 32px; height: 32px; display: block;">
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>

                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>

                <div class="reply-buttons" id="reply-buttons">
                    <button class="reply-btn" id="show-reply">
                        <svg viewBox="0 0 24 24">
                            <path d="M10 9V5l-7 7 7 7v-4.1c5 0 8.5 1.6 11 5.1-1-5-4-10-11-11z"/>
                        </svg>
                        Reply
                    </button>
                    <button class="forward-btn">
                        <svg viewBox="0 0 24 24">
                            <path d="M12 8V4l8 8-8 8v-4H4v-8h8z"/>
                        </svg>
                        Forward
                    </button>
                </div>

                <div class="reply-compose" id="reply-compose">
                    <div class="compose-header">
                        <div class="compose-avatar">
                            <img src="[[CUSTOMER_AVATAR_URL]]" alt="[[CUSTOMER_NAME]]" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 100 100\'%3E%3Ccircle cx=\'50\' cy=\'50\' r=\'50\' fill=\'%23667eea\'/%3E%3Ctext x=\'50\' y=\'50\' text-anchor=\'middle\' dy=\'.3em\' fill=\'white\' font-size=\'35\' font-family=\'Arial\'%3E[[CUSTOMER_INITIALS]]%3C/text%3E%3C/svg%3E';">
                        </div>
                        <div class="compose-recipient">
                            <svg viewBox="0 0 24 24">
                                <path d="M10 9V5l-7 7 7 7v-4.1c5 0 8.5 1.6 11 5.1-1-5-4-10-11-11z"/>
                            </svg>
                            <span class="recipient-name">[[BRAND_NAME]]</span>
                        </div>
                        <div class="compose-popout">
                            <svg viewBox="0 0 24 24">
                                <path d="M19 19H5V5h7V3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z"/>
                            </svg>
                        </div>
                    </div>
                    <textarea class="reply-textarea" id="reply-text" placeholder=""></textarea>
                    <div class="compose-signature">
                        <div class="signature-divider">⋯</div>
                        <div><strong>[[CUSTOMER_NAME]]</strong></div>
                        <div>[[CUSTOMER_TITLE]] | [[CUSTOMER_COMPANY]]</div>
                        <div>Mobile: [[CUSTOMER_MOBILE]]</div>
                        <div>[[CUSTOMER_EMAIL]]</div>
                    </div>
                    <div class="compose-toolbar">
                        <div class="toolbar-group">
                            <div class="toolbar-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M12.5 8c-2.65 0-5.05.99-6.9 2.6L2 7v9h9l-3.62-3.62c1.39-1.16 3.16-1.88 5.12-1.88 3.54 0 6.55 2.31 7.6 5.5l2.37-.78C21.08 11.03 17.15 8 12.5 8z"/>
                                </svg>
                            </div>
                            <div class="toolbar-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M18.4 10.6C16.55 8.99 14.15 8 11.5 8c-4.65 0-8.58 3.03-9.96 7.22L3.9 16c1.05-3.19 4.05-5.5 7.6-5.5 1.95 0 3.73.72 5.12 1.88L13 16h9V7l-3.6 3.6z"/>
                                </svg>
                            </div>
                        </div>
                        <div class="toolbar-separator"></div>
                        <div class="toolbar-group">
                            <div class="toolbar-btn"><strong>B</strong></div>
                            <div class="toolbar-btn"><em>I</em></div>
                            <div class="toolbar-btn"><u>U</u></div>
                        </div>
                    </div>
                    <div class="compose-actions">
                        <div class="send-btn-group">
                            <button class="send-btn" id="send-btn">Send</button>
                            <button class="send-dropdown">
                                <svg viewBox="0 0 24 24">
                                    <path d="M7 10l5 5 5-5z"/>
                                </svg>
                            </button>
                        </div>
                        <div class="compose-bottom-icons">
                            <div class="toolbar-btn">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/>
                                </svg>
                            </div>
                            <div class="toolbar-btn">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M16.5 6v11.5c0 2.21-1.79 4-4 4s-4-1.79-4-4V5c0-1.38 1.12-2.5 2.5-2.5s2.5 1.12 2.5 2.5v10.5c0 .55-.45 1-1 1s-1-.45-1-1V6H10v9.5c0 1.38 1.12 2.5 2.5 2.5s2.5-1.12 2.5-2.5V5c0-2.21-1.79-4-4-4S7 2.79 7 5v12.5c0 3.04 2.46 5.5 5.5 5.5s5.5-2.46 5.5-5.5V6h-1.5z"/>
                                </svg>
                            </div>
                            <div class="toolbar-btn">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M3.9 12c0-1.71 1.39-3.1 3.1-3.1h4V7H7c-2.76 0-5 2.24-5 5s2.24 5 5 5h4v-1.9H7c-1.71 0-3.1-1.39-3.1-3.1zM8 13h8v-2H8v2zm9-6h-4v1.9h4c1.71 0 3.1 1.39 3.1 3.1s-1.39 3.1-3.1 3.1h-4V17h4c2.76 0 5-2.24 5-5s-2.24-5-5-5z"/>
                                </svg>
                            </div>
                            <div class="toolbar-btn">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm3.5-9c.83 0 1.5-.67 1.5-1.5S16.33 8 15.5 8 14 8.67 14 9.5s.67 1.5 1.5 1.5zm-7 0c.83 0 1.5-.67 1.5-1.5S9.33 8 8.5 8 7 8.67 7 9.5 7.67 11 8.5 11zm3.5 6.5c2.33 0 4.31-1.46 5.11-3.5H6.89c.8 2.04 2.78 3.5 5.11 3.5z"/>
                                </svg>
                            </div>
                            <div class="toolbar-btn">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/>
                                </svg>
                            </div>
                        </div>
                        <div class="compose-delete">
                            <svg viewBox="0 0 24 24">
                                <path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
                            </svg>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script id="email-messages-data" type="application/json">[[EMAIL_MESSAGES_ARRAY]]</script>
    <script>
        const jsonText = document.getElementById('email-messages-data').textContent;
        console.log('JSON text content:', jsonText);
        window.emailMessages = JSON.parse(jsonText);
        console.log('Parsed emailMessages:', window.emailMessages);
    </script>
    <script>
        const showReplyBtn = document.getElementById('show-reply');
        const replyCompose = document.getElementById('reply-compose');
        const replyText = document.getElementById('reply-text');
        const sendBtn = document.getElementById('send-btn');
        const threadContainer = document.getElementById('thread-container');
        const replyButtons = document.getElementById('reply-buttons');
        const contentArea = document.querySelector('.content-area');

        let currentMessageIndex = 0;
        let isTyping = false;
        let pendingCustomerMessage = null;
        let justFocused = false;

        function getCurrentTime() {
            const now = new Date();
            return now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
        }

        function addMessageToThread(sender, senderEmail, message, avatarLetter, avatarClass, isAgent = false, avatarUrl = '') {
            const messageHeader = document.createElement('div');
            messageHeader.className = 'message-header';
            messageHeader.style.marginTop = '32px';

            const badge = isAgent ? '<span class="badge">[[BRAND_NAME]] VIRTUAL ADVISOR</span>' : '';

            let avatarHtml;
            if (avatarUrl && avatarUrl.trim() !== '' && !avatarUrl.includes('[[')) {
                // The agent avatar is the brand logo, so sit it on the Logo
                // Background Color (use `background` to clear the .agent gradient).
                // The subscriber avatar stays transparent.
                const avBg = isAgent ? '[[LOGO_BG_COLOR]]' : 'transparent';
                avatarHtml = `<div class="sender-avatar ${avatarClass}" style="background: ${avBg} !important;"><img src="${avatarUrl}" alt="${sender}" style="width: 100%; height: 100%; object-fit: cover;"></div>`;
            } else {
                avatarHtml = `<div class="sender-avatar ${avatarClass}">${avatarLetter}</div>`;
            }

            messageHeader.innerHTML = `
                ${avatarHtml}
                <div class="sender-info">
                    <div>
                        <span class="sender-name">${sender}</span>
                        <span class="sender-email">&lt;${senderEmail}&gt;</span>
                        ${badge}
                    </div>
                    <div class="recipient-info">to ${isAgent ? '[[CUSTOMER_FIRST_NAME]]' : '[[BRAND_NAME]]'}</div>
                </div>
                <div class="message-time">${getCurrentTime()}</div>
                <div class="message-actions">
                    <div class="icon-btn">
                        <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAB7UlEQVR4Ae1Wi03DMBBlBEZghI5g1ffTl27QbEA3oBvABKQblA06QkboCNkA0JNk6p4qkhASGSknnZSPfT77vXvnu8UWW2yxi5FZIKNQbIJR6BCV6yKTM7MHUvkklTaEcF8evCovSBBOIvviEmSVM5JLp1hWcswVEstdVR/LgVe48QmS8qkcackTE27TMySnCGlJCUXVOiq/Xt65LkJakge8GwU8zy45WJyZVyKyYbOKlZ/As1ucu/4uR4zFPNABMUYlTSLPgAaLQDoSp7o8mmxTDHeK3j1fG6yFjZDqrjNB7C5iMAL09Khy9nH6bixHYNDJksn+9o75hBNGMaBjsHEVmFd+Pr7hH8ZgLDaNudiMj4v/bvrvkgTkgG+UJLmTxRojZSRufFBwZXAcFJVDI4ps/qyCPTQopiGF5znraDFJkvBjF7FZtXZzGsQal03/Cm8H3XJMDogx583lvQe8360Qc2ftvb5Y0PrMwbdW2uW9et6rlVFI0KMQUJm+gMC3XKbmvBy0SdtynuXJiMjWd5VJOQhNzKUiXQo6/IhTn4WHaEk/N37drY0rL0e+rc3CP78ooLvSzKx6nTeTaeCtGwgKpa+4T8pDFIOHs+9cDzs2NRn/PJxd5mBH2/uYhIe4143YuYNd3+4WW+yf2BfK3SI5uCgSUAAAAABJRU5ErkJggg==" alt="Star" style="width: 20px; height: 20px;">
                    </div>
                    <div class="icon-btn">
                        <svg viewBox="0 0 24 24" fill="#5f6368" style="width: 20px; height: 20px;">
                            <path d="M10 9V5l-7 7 7 7v-4.1c5 0 8.5 1.6 11 5.1-1-5-4-10-11-11z"/>
                        </svg>
                    </div>
                    <div class="icon-btn">
                        <svg viewBox="0 0 24 24" fill="#5f6368" style="width: 20px; height: 20px;">
                            <path d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/>
                        </svg>
                    </div>
                </div>
            `;

            const messageCard = document.createElement('div');
            messageCard.className = 'message-card';

            // Debug: log the raw message
            console.log('Raw message text:', message);

            // Process message - preserve HTML tags, handle markdown-style formatting
            const lines = message.split('\n').map(line => {
                line = line.trim();
                if (!line) return '';

                // If line doesn't contain any HTML, apply markdown-style formatting
                if (!line.includes('<')) {
                    // Handle **bold** markdown
                    if (line.startsWith('**') && line.endsWith('**')) {
                        return `<p><strong>${line.slice(2, -2)}</strong></p>`;
                    }
                    // Handle bullet points
                    if (line.startsWith('•') || line.startsWith('✓')) {
                        return `<p>${line}</p>`;
                    }
                }

                // For all other lines (including those with HTML), wrap in <p> tag
                return `<p>${line}</p>`;
            });

            const formattedMessage = lines.join('');
            console.log('Formatted message HTML:', formattedMessage);
            messageCard.innerHTML = `<div class="message-body">${formattedMessage}</div>`;

            threadContainer.appendChild(messageHeader);
            threadContainer.appendChild(messageCard);

            // Highlight the agent's reply so an off-screen arrival is noticeable.
            if (isAgent) {
                messageCard.classList.add('just-arrived');
                setTimeout(() => messageCard.classList.remove('just-arrived'), 2600);
            }
            // scrollIntoView bubbles across the same-origin VF iframe to scroll the
            // preview pane itself (contentArea.scrollTop only scrolled an inner div,
            // so the reply landed below the fold and you had to scroll by hand).
            try {
                messageHeader.scrollIntoView({ behavior: 'smooth', block: 'center' });
            } catch (e) {
                if (contentArea) contentArea.scrollTop = contentArea.scrollHeight;
            }
        }

        function startTypingSimulation(messageText) {
            if (isTyping) return;
            isTyping = true;

            sendBtn.disabled = true;
            replyText.value = '';

            let currentIndex = 0;
            let typoScheduled = false;
            let inTypo = false;

            // Schedule a random typo somewhere in the message (10% chance)
            const shouldHaveTypo = Math.random() < 0.1;
            const typoPosition = shouldHaveTypo ? Math.floor(Math.random() * Math.max(1, messageText.length - 5)) + 3 : -1;

            function typeNextChar() {
                if (currentIndex >= messageText.length) {
                    sendBtn.disabled = false;
                    isTyping = false;
                    return;
                }

                // Check if we should make a typo here
                if (!inTypo && currentIndex === typoPosition) {
                    inTypo = true;
                    const wrongChars = 'abcdefghijklmnopqrstuvwxyz';
                    const wrongChar = wrongChars[Math.floor(Math.random() * wrongChars.length)];
                    replyText.value += wrongChar;
                    replyText.scrollTop = replyText.scrollHeight;

                    // Pause, then backspace and type correct character
                    setTimeout(() => {
                        replyText.value = replyText.value.slice(0, -1);
                        setTimeout(() => {
                            replyText.value += messageText[currentIndex];
                            currentIndex++;
                            replyText.scrollTop = replyText.scrollHeight;
                            inTypo = false;
                            scheduleNextChar();
                        }, 80 + Math.random() * 60);
                    }, 300 + Math.random() * 200);
                    return;
                }

                // Type the current character
                replyText.value += messageText[currentIndex];
                currentIndex++;
                replyText.scrollTop = replyText.scrollHeight;

                scheduleNextChar();
            }

            function scheduleNextChar() {
                if (currentIndex >= messageText.length) {
                    sendBtn.disabled = false;
                    isTyping = false;
                    return;
                }

                // Variable typing speed: 40-80ms per character (faster)
                let delay = 40 + Math.random() * 40;

                // Add occasional thinking pauses after spaces or punctuation
                const prevChar = messageText[currentIndex - 1];
                if (prevChar === ' ' && Math.random() < 0.12) {
                    delay += 100 + Math.random() * 150; // shorter pause between words
                } else if (['.', ',', '!', '?'].includes(prevChar) && Math.random() < 0.25) {
                    delay += 150 + Math.random() * 200; // shorter pause after punctuation
                }

                setTimeout(typeNextChar, delay);
            }

            // Start typing
            typeNextChar();
        }

        function processNextMessage() {
            if (currentMessageIndex >= window.emailMessages.length) {
                // All messages processed, hide reply buttons
                replyButtons.style.display = 'none';
                return;
            }

            const currentMsg = window.emailMessages[currentMessageIndex];

            if (currentMsg.sender === 'user') {
                // Customer message - show compose box with cursor, wait for user to trigger typing
                pendingCustomerMessage = currentMsg.text;
                replyCompose.classList.add('active');
                replyButtons.style.display = 'none';

                setTimeout(() => {
                    if (contentArea) {
                        replyCompose.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }
                    // Focus after scroll, but don't trigger typing yet
                    justFocused = true;
                    replyText.focus();
                    setTimeout(() => { justFocused = false; }, 100);
                }, 100);
            } else {
                // Agent message - show immediately
                addMessageToThread(
                    '[[AGENT_NAME]]',
                    'agent@[[BRAND_DOMAIN]]',
                    currentMsg.text,
                    '[[AGENT_INITIALS]]',
                    'agent',
                    true,
                    '[[AGENT_AVATAR_URL]]'
                );

                currentMessageIndex++;

                // Always show reply button after agent message
                replyButtons.style.display = 'flex';
            }
        }

        function handleSend() {
            const message = replyText.value.trim();
            if (!message || isTyping) return;

            sendBtn.disabled = true;
            sendBtn.textContent = 'Sending...';

            // Add customer message
            addMessageToThread(
                '[[CUSTOMER_NAME]]',
                '[[CUSTOMER_EMAIL]]',
                message,
                '[[CUSTOMER_INITIALS]]',
                'user',
                false,
                '[[CUSTOMER_AVATAR_URL]]'
            );

            replyText.value = '';
            replyCompose.classList.remove('active');

            currentMessageIndex++;

            // Show agent response after delay
            setTimeout(() => {
                sendBtn.disabled = false;
                sendBtn.textContent = 'Send';
                processNextMessage();
            }, 1500);
        }

        // Event listeners
        showReplyBtn.addEventListener('click', () => {
            processNextMessage();
        });

        sendBtn.addEventListener('click', handleSend);

        // Trigger typing simulation when user clicks in compose box
        replyText.addEventListener('click', () => {
            if (pendingCustomerMessage && !isTyping && !justFocused) {
                startTypingSimulation(pendingCustomerMessage);
                pendingCustomerMessage = null;
            }
        });

        replyText.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
                handleSend();
            }
        });

        // Show reply button initially if there are messages
        if (window.emailMessages && window.emailMessages.length > 0) {
            replyButtons.style.display = 'flex';
        }
    </script>
</body>
</html>
