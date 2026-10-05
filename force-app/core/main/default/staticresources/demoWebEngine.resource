/* demoWebEngine — Adaptive Web content engine, ported VERBATIM (no edits) from
   the Cumulus Experience Generator public/script.js. Extracted by exact line
   ranges; see /tmp/web_engine_manifest.md. 31 symbols (11 consts + 20 fns) +
   the required applyAdaptiveMatrixOverrides() load call. Engine reads live DOM
   (getElementById) and prefers input .value over the formData param, so the
   host page must provide the 126 shim inputs (see /tmp/web_shim_fields.txt). */

/* ===== constants ===== */
const ADAPTIVE_GENERIC_AGENT_GREETING =
  "Hi ${firstName}, welcome back! I'm Penny, your ${brandName} AI assistant.";

const ADAPTIVE_WEB_COPY_BY_SUB_INDUSTRY = {
  retailBanking: {
    coldHeroEyebrow: "Life simplified",
    coldHeroHeading: "Comprehensive financial solutions for every stage of life.",
    coldHeroParagraph1: "From everyday banking and insurance to enterprise commercial lending and wealth management, ${brandName} is your trusted partner.",
    coldHeroParagraph2: "Life, it's one less thing to worry about. Open a free account with ${brandName} today — explore services and see how checking, savings, borrowing, and investing fit together.",
    homepageCtaText: "Explore Everyday Banking",
    homeMarketInsights: {
      sectionSubtitle:
        "Short reads on saving, credit, and investing—informational only, not advice.",
      cards: [
        {
          eyebrow: "Saving",
          title: "Build savings habits that stick",
          body: "Automatic transfers, clear goals, and the right account mix make progress steady—small steps beat an all-or-nothing approach.",
        },
        {
          eyebrow: "Credit cards",
          title: "Choose rewards that match how you spend",
          body: "Travel points, cash back, or a low-rate card each fit different habits. Comparing fees and perks helps you earn more on purchases you already make.",
        },
        {
          eyebrow: "Investing",
          title: "How to think about IRA investments",
          body: "Time horizon, diversification, and comfort with volatility usually matter more than timing the market—a disciplined plan supports long-term goals.",
        },
      ],
    },
    categoryPage: {
      heroBgImage:
        "https://images.unsplash.com/photo-1579621970588-a35d0e7ab9b6?auto=format&fit=crop&w=2400&q=80",
      catHeroTitle: "Personal Banking, Elevated.",
      catHeroSubtitle: "Everything you need to manage, save, and borrow in one integrated platform.",
      marketInsightsIntro:
        "Timely ideas for budgeting, borrowing, and planning. When you want next steps for your situation, open the chat and ask Penny—your ${brandName} assistant in this demo.",
      services: [
        {
          iconClass: "fa-building-columns",
          title: "Checking & Savings",
          description: "Fee-free accounts with high-yield options",
        },
        {
          iconClass: "fa-credit-card",
          title: "Credit Cards",
          description: "Cashback and travel rewards tailored to your lifestyle",
        },
        {
          iconClass: "fa-car",
          title: "Borrowing",
          description: "Auto, Home, and Personal loans with rapid decisions",
        },
      ],
      whyChooseUsTitle: "Award-Winning Digital Banking",
      whyChooseUsText:
        "Manage your entire financial life from the palm of your hand. Deposit checks, track credit scores, and apply for loans instantly through our top-rated mobile app.",
      whyChooseUsImage:
        "https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=1200&q=80",
      article1Title: "Before you refinance: questions worth asking",
      article2Title: "Everyday steps that strengthen digital banking security",
    },
    useCases: {
      autoLoan: {
        name: "Auto Loan Pre-Approval",
        heroAssets: {
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472484/confident-student-in-shared-space-with-laptop_collagestyle_zeay8z.avif",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479242/1a-blogposts-When-Refinancing-an-Auto-Loan-Makes-Sense_yc7s9g.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479847/sports-car-insurance_mstufu.jpg",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479444/Livery-Insurance-Close-up-Portrait-of-a-Woman-Driver-of-a-Car-Service-Smiling-at-the-Camera_vynex8.webp",
        },
        vanillaHeroTitle: "Finance your next vehicle with confidence.",
        vanillaHeroSubtext:
          "Compare term lengths and payment paths for your auto loan, then continue with a lending specialist.",
        userIntentString: "I want an auto loan.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three auto loan structures to review—rates shown; a specialist confirms your final offer.",
        adaptiveOverlayTitle: "Options tailored to your session",
        adaptiveOverlaySubtitle:
          "Review three starting points below, then continue in chat or with a specialist.",
        adaptiveFooterNote: "Retail Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can finalize your request.",
        homeMarketInsights: {
          sectionSubtitle:
            "Resources for everyday money management.",
          cards: [
            {
              eyebrow: "Student loans",
              title: "Student loan planning for graduates starting repayment",
              body: "The image of a student with a backpack supports this topic on payment planning and early repayment choices.",
            },
            {
              eyebrow: "Credit cards",
              title: "Travel credit card value for frequent trip spending",
              body: "The beach travel card image matches this card-comparison topic around points, fees, and redemption value.",
            },
            {
              eyebrow: "Retirement",
              title: "Retirement income planning across family stages",
              body: "The grandparent reading with grandkids image supports this retirement planning topic on long-term household goals.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(415) 234-5678",
          company: "Acme Corp",
          zipCode: "94105",
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Auto financing",
              title: "When auto refinancing can lower total cost",
              body: "The auto-financing article image supports this topic on rate changes, term resets, and monthly payment tradeoffs.",
            },
            {
              eyebrow: "Insurance",
              title: "Sports car insurance and premium drivers",
              body: "The sports car image matches this insurance topic on coverage levels, deductibles, and premium risk factors.",
            },
            {
              eyebrow: "Rates",
              title: "Locking your rate before final vehicle selection",
              body: "The smiling driver image reflects this rate-lock topic around pre-approval timing and document readiness.",
            },
          ],
        },
        cards: [
          {
            recommended: false,
            smallTag: "Fast Payoff",
            title: "36-Month Auto Loan",
            iconClass: "fa-car",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "APR", value: "5.49%" }, { label: "TERM", value: "36 mo" }],
            features: [
              "Lowest interest rate",
              "Pay off your vehicle faster",
              "No prepayment penalties",
              "Same-day funding",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Balanced",
            title: "60-Month Auto Loan",
            iconClass: "fa-car",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "APR", value: "6.25%" }, { label: "TERM", value: "60 mo" }],
            features: [
              "Balanced monthly payments",
              "Competitive interest rate",
              "Rate lock for 30 days",
              "Automatic payment discount",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Low Payment",
            title: "72-Month Auto Loan",
            iconClass: "fa-car",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "APR", value: "6.99%" }, { label: "TERM", value: "72 mo" }],
            features: [
              "Lowest monthly payment",
              "Maximum vehicle purchasing power",
              "100% digital application",
              "Skip a payment program",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      mortgage: {
        name: "First-Time Homebuyer",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479639/exterior-cape-cod-house-mem-interiors-pc-r-brad-knipstein_d4kp5r.webp",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472484/confident-student-in-shared-space-with-laptop_collagestyle_zeay8z.avif",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479720/quarters-stacked-on-a-table-and-a-jar-with-a-growing-sprout_dgntpn.jpg",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479544/1-JacobWackerhausen-417d5105246c4947bc3cad2a961af80a_j8cfgh.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774480084/milan2099-61cf06cdda72490bb75bb448fd03aaae_r62pz0.jpg",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479444/Livery-Insurance-Close-up-Portrait-of-a-Woman-Driver-of-a-Car-Service-Smiling-at-the-Camera_vynex8.webp",
        },
        vanillaHeroTitle: "Your dream home, within reach.",
        vanillaHeroSubtext:
          "Explore competitive mortgage rates and first-time buyer programs designed to get you the keys faster.",
        userIntentString: "I am looking to buy my first home and need a mortgage.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Congratulations! That's a huge milestone. I see your savings are healthy for a down payment. Let me pull up our current mortgage rates.",
        adaptiveOverlayTitle: "Mortgage options for your first home",
        adaptiveOverlaySubtitle:
          "Compare fixed-rate, accelerated payoff, and adjustable programs with a lending specialist.",
        adaptiveFooterNote: "Retail Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can finalize your request.",
        homeMarketInsights: {
          sectionSubtitle:
            "Mortgage and home financing resources.",
          cards: [
            {
              eyebrow: "Student loans",
              title: "Student debt planning while preparing for homeownership",
              body: "The student-with-backpack image supports this topic on balancing loan repayment with future home goals.",
            },
            {
              eyebrow: "Rate planning",
              title: "Why early rate planning matters for first-time buyers",
              body: "The family-at-home image matches this lock-rate topic around payment certainty before purchase.",
            },
            {
              eyebrow: "Savings",
              title: "Building cash reserves before home purchase",
              body: "The growing-money image supports this savings-rate topic for down payment and closing-cost readiness.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Mortgage trends",
              title: "Mortgage rate trends for first-time buyers",
              body: "The mortgage-rates article image supports this topic on affordability, payment changes, and timing choices.",
            },
            {
              eyebrow: "First-time buyer",
              title: "Checklist milestones before making an offer",
              body: "The first-time buyer checklist image matches this topic on pre-approval, inspection, and closing steps.",
            },
            {
              eyebrow: "Rate strategy",
              title: "Rate lock planning before closing",
              body: "The smiling driver image is used here for the lock-rate note and supports payment certainty and timing decisions.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(415) 234-5678",
          company: "Acme Corp",
          zipCode: "94105",
        },
        cards: [
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Predictable",
            title: "30-Year Fixed Mortgage",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "RATE", value: "6.50%" }, { label: "APR", value: "6.65%" }],
            features: [
              "Predictable monthly payments",
              "First-time buyer grants available",
              "Lock your rate for 60 days",
              "Dedicated loan officer",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Fast Equity",
            title: "15-Year Fixed Mortgage",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "RATE", value: "5.99%" }, { label: "APR", value: "6.15%" }],
            features: [
              "Build equity twice as fast",
              "Lower interest rate",
              "Save thousands in total interest",
              "Fast-track closing",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Flexible",
            title: "5/1 ARM",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "INITIAL RATE", value: "5.75%" }, { label: "APR", value: "6.85%" }],
            features: [
              "Lowest initial payment",
              "Fixed for the first 5 years",
              "Ideal if you plan to move soon",
              "No prepayment penalties",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      creditCard: {
        name: "Credit Card Match",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479242/1a-blogposts-When-Refinancing-an-Auto-Loan-Makes-Sense_yc7s9g.jpg",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472577/young-woman-laptop-home_padiak.jpg",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201707/Sixty-and-Me_How-to-Live-in-Luxury-in-Retirement_-No-Matter-Your-Budget_xcg3ws.jpg",
        },
        vanillaHeroTitle: "Rewarding your everyday.",
        vanillaHeroSubtext:
          "From cash back to travel perks, find the card that fits your lifestyle and maximizes your spending.",
        userIntentString: "I travel frequently and want a new rewards credit card.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three cards that often fit travel-heavy spend—compare perks and fees, then continue with a specialist.",
        adaptiveOverlayTitle: "Cards matched to your spend",
        adaptiveOverlaySubtitle:
          "Compare travel rewards, flat cash back, and premium benefits—then continue in chat or with a specialist.",
        adaptiveFooterNote: "Retail Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can finalize your request.",
        homeMarketInsights: {
          sectionSubtitle:
            "Credit and borrowing insights.",
          cards: [
            {
              eyebrow: "Auto lending",
              title: "Auto loan options and pre-approval basics",
              body: "The driver-with-keys image supports this topic on loan setup, term choices, and purchase readiness.",
            },
            {
              eyebrow: "Auto refinancing",
              title: "When refinancing an auto loan can help",
              body: "The auto-refinance article image matches this topic on rate review and payment reduction opportunities.",
            },
            {
              eyebrow: "Student loans",
              title: "Student loan consolidation and monthly payment relief",
              body: "The young professional phone image supports this consolidation topic and repayment simplification.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Travel rewards",
              title: "Travel rewards card fit for frequent trips",
              body: "The travel card image supports this topic on annual fee value, miles structure, and redemption flexibility.",
            },
            {
              eyebrow: "Everyday spend",
              title: "Everyday spend patterns that build rewards",
              body: "The coffee shop checkout image matches this topic on routine spend, statement credits, and reward accumulation.",
            },
            {
              eyebrow: "Lifestyle planning",
              title: "Premium card perks and long-term lifestyle goals",
              body: "The older couple on a yacht image supports this topic on premium benefits and retirement travel priorities.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(415) 234-5678",
          company: "Acme Corp",
          zipCode: "94105",
        },
        cards: [
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Best Match",
            title: "Premium Travel Rewards",
            iconClass: "fa-plane",
            iconBgClass: "bg-sky-50",
            metrics: [
              { label: "ANNUAL FEE", value: "$95" },
              { label: "SIGN-UP BONUS", value: "50k Miles" },
            ],
            features: [
              "3x miles on flights and hotels",
              "Complimentary lounge access",
              "No foreign transaction fees",
              "TSA PreCheck statement credit",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "No Fee",
            title: "Cash Back Plus",
            iconClass: "fa-credit-card",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [
              { label: "ANNUAL FEE", value: "$0" },
              { label: "CASH BACK", value: "2% Flat" },
            ],
            features: [
              "2% cash back on all purchases",
              "0% Intro APR for 15 months",
              "No category tracking required",
              "Zero fraud liability",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Luxury",
            title: "Platinum Reserve",
            iconClass: "fa-gem",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [
              { label: "ANNUAL FEE", value: "$450" },
              { label: "SIGN-UP BONUS", value: "100k Miles" },
            ],
            features: [
              "5x miles on flights and dining",
              "$300 annual travel credit",
              "Global Entry fee credit",
              "24/7 Premium Concierge",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      mortgageRefi: {
        name: "Mortgage Refinance",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479639/exterior-cape-cod-house-mem-interiors-pc-r-brad-knipstein_d4kp5r.webp",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472577/young-woman-laptop-home_padiak.jpg",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201707/Sixty-and-Me_How-to-Live-in-Luxury-in-Retirement_-No-Matter-Your-Budget_xcg3ws.jpg",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479544/1-JacobWackerhausen-417d5105246c4947bc3cad2a961af80a_j8cfgh.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
        },
        vanillaHeroTitle: "Optimize your mortgage strategy",
        vanillaHeroSubtext:
          "Take advantage of changing rates to lower your monthly payment, pay off your loan faster, or get cash out for renovations.",
        userIntentString: "Rates are dropping and I want to refinance my mortgage.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Great timing! Based on your current home equity and loan balance, I've run three different refinance scenarios for you to compare.",
        adaptiveOverlayTitle: "Refinance options for your home",
        adaptiveOverlaySubtitle:
          "Compare payment reduction, faster payoff, and cash-out structures with a mortgage specialist.",
        adaptiveFooterNote: "Retail Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can finalize your request.",
        homeMarketInsights: {
          sectionSubtitle:
            "Refinancing and financial planning resources.",
          cards: [
            {
              eyebrow: "Savings habits",
              title: "Daily spending habits and long-term savings progress",
              body: "The coffee shop image supports this topic on budgeting behavior and building savings over time.",
            },
            {
              eyebrow: "Retirement planning",
              title: "Retirement lifestyle planning and income confidence",
              body: "The older couple on a yacht image matches this topic on retirement goals and future income planning.",
            },
            {
              eyebrow: "Student loan consolidation",
              title: "Consolidation strategies for simpler repayment",
              body: "The young professional phone image supports this topic on combining loans and managing monthly payments.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Mortgage rates",
              title: "Mortgage rate trends and refinance timing",
              body: "The mortgage-rates article image supports this topic on timing a refinance and comparing payment outcomes.",
            },
            {
              eyebrow: "Rate lock",
              title: "Rate lock planning for stable monthly payments",
              body: "The family-at-home image matches this lock-rate topic focused on payment stability and closing readiness.",
            },
            {
              eyebrow: "Credit strategy",
              title: "Credit card debt and refinance tradeoffs",
              body: "The credit card image supports this topic on debt structure, consolidation choices, and total borrowing cost.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(415) 234-5678",
          company: "Acme Corp",
          zipCode: "94105",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Lowest Payment",
            title: "30-Year Fixed Refi",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "RATE", value: "5.50%" }, { label: "APR", value: "5.65%" }],
            features: [
              "Drop your monthly payment",
              "Improve monthly cash flow",
              "No prepayment penalty",
              "Escrow management included",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Best Value",
            title: "15-Year Fixed Refi",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "RATE", value: "4.99%" }, { label: "APR", value: "5.15%" }],
            features: [
              "Pay off your home faster",
              "Save thousands in total interest",
              "Build equity rapidly",
              "Dedicated closing team",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Liquidity",
            title: "Cash-Out Refinance",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "RATE", value: "5.85%" }, { label: "CASH OUT", value: "Up to $50k" }],
            features: [
              "Fund home improvements",
              "Consolidate high-interest debt",
              "Leverage existing home equity",
              "Potential tax deductions",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      homeEquity: {
        name: "Home Equity (HELOC)",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472577/young-woman-laptop-home_padiak.jpg",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479072/young-couple-renovating-home-and-dancing-in-living-room-EIF03304_wzfeup.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478992/AdobeStock_300463851-scaled_v86hcy.jpg",
        },
        vanillaHeroTitle: "Invest in your home's future.",
        vanillaHeroSubtext:
          "Leverage your home's equity to fund renovations, consolidate debt, or cover major life expenses with flexible borrowing options.",
        userIntentString: "I want to remodel my kitchen and need to tap into my home equity.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "A kitchen remodel is a fantastic investment! Based on your current estimated home value, I've pulled three different ways you can leverage your equity.",
        adaptiveOverlayTitle: "Ways to use your home equity",
        adaptiveOverlaySubtitle:
          "Compare a revolving line, a fixed lump-sum loan, and cash-out refinance with a home lending specialist.",
        adaptiveFooterNote: "Retail Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can finalize your request.",
        homeMarketInsights: {
          sectionSubtitle:
            "Home equity and savings strategies.",
          cards: [
            {
              eyebrow: "Retirement planning",
              title: "Retirement planning across generations",
              body: "The grandparent reading with grandkids image supports this topic on long-term family financial planning.",
            },
            {
              eyebrow: "Student loans",
              title: "Consolidation options for monthly payment relief",
              body: "The young professional phone image matches this student loan consolidation topic and repayment planning.",
            },
            {
              eyebrow: "Savings habits",
              title: "Everyday savings behaviors that support larger goals",
              body: "The coffee shop image supports this topic on routine spending choices and steady savings progress.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Home repair",
              title: "Using a HELOC for renovation and repair projects",
              body: "The renovating-couple image supports this topic on project funding, staged draws, and repayment planning.",
            },
            {
              eyebrow: "Credit cards",
              title: "How card usage affects household borrowing strategy",
              body: "The travel credit card image matches this topic on card balances, rates, and total monthly debt planning.",
            },
            {
              eyebrow: "Rate planning",
              title: "Locking rates before larger home upgrade spend",
              body: "The kitchen renovation couple image supports this note on rate timing before major improvement costs.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(415) 234-5678",
          company: "Acme Corp",
          zipCode: "94105",
        },
        cards: [
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Flexible",
            title: "Home Equity Line of Credit",
            iconClass: "fa-chart-line",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "RATE", value: "7.25%" }, { label: "LINE", value: "Up to $100k" }],
            features: [
              "Draw funds only as you need them",
              "Pay interest only on what you use",
              "Reusable credit line",
              "Variable interest rate",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Predictable",
            title: "Fixed Home Equity Loan",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "RATE", value: "6.99%" }, { label: "TERM", value: "15 Years" }],
            features: [
              "Receive a lump sum upfront",
              "Fixed monthly payments",
              "Ideal for one-time large projects",
              "Fixed interest rate",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Consolidated",
            title: "Cash-Out Refinance",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "RATE", value: "5.85%" }, { label: "CASH OUT", value: "Up to $75k" }],
            features: [
              "Replace your existing mortgage",
              "Potentially lower your primary rate",
              "One single monthly payment",
              "Maximize your borrowing power",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      depositCapture: {
        name: "Deposit Capture / High-Yield",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479329/shutterstock_1107968786_vagxeh.jpg",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479072/young-couple-renovating-home-and-dancing-in-living-room-EIF03304_wzfeup.jpg",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479720/quarters-stacked-on-a-table-and-a-jar-with-a-growing-sprout_dgntpn.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472577/young-woman-laptop-home_padiak.jpg",
        },
        vanillaHeroTitle: "Make your money work harder.",
        vanillaHeroSubtext:
          "Grow your savings with industry-leading rates on high-yield accounts and certificates of deposit designed for your timeline.",
        userIntentString: "I have $50k sitting in a standard checking account and want to earn more interest.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "You should absolutely be earning a yield on that balance. Here are three secure options to maximize your return while maintaining the liquidity you need.",
        adaptiveOverlayTitle: "Savings and CD options",
        adaptiveOverlaySubtitle:
          "Compare high-yield savings, a short-term CD, and a money market tier—then continue with a specialist.",
        adaptiveFooterNote: "Retail Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can finalize your request.",
        homeMarketInsights: {
          sectionSubtitle:
            "Savings and financial education.",
          cards: [
            {
              eyebrow: "Travel rewards",
              title: "Travel credit card product highlights",
              body: "The travel card and beach image supports this topic on rewards features and card fit by spending style.",
            },
            {
              eyebrow: "Home equity",
              title: "HELOC and home repair funding basics",
              body: "The home renovation image matches this topic on repair planning and flexible borrowing options.",
            },
            {
              eyebrow: "Auto lending",
              title: "Auto loan pre-approval and borrowing setup",
              body: "The driver-with-keys image supports this topic on pre-approval steps and loan structure choices.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Savings rates",
              title: "Savings rates and account growth basics",
              body: "The growing money image supports this topic on APY, balance growth, and account selection.",
            },
            {
              eyebrow: "Long-term goals",
              title: "Connecting current savings to retirement goals",
              body: "The grandparent reading image matches this topic on linking short-term savings with long-term retirement planning.",
            },
            {
              eyebrow: "Everyday habits",
              title: "Daily spending habits that support savings",
              body: "The coffee shop checkout image supports this topic on routine behavior, transfer habits, and steady progress.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(415) 234-5678",
          company: "Acme Corp",
          zipCode: "94105",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Liquid",
            title: "High-Yield Savings",
            iconClass: "fa-piggy-bank",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "APY", value: "4.35%" }, { label: "MINIMUM", value: "$0" }],
            features: [
              "Total liquidity and easy transfers",
              "No monthly maintenance fees",
              "FDIC insured up to $250k",
              "Interest compounded daily",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Highest Rate",
            title: "6-Month CD",
            iconClass: "fa-certificate",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "APY", value: "5.10%" }, { label: "TERM", value: "6 Months" }],
            features: [
              "Lock in our highest guaranteed rate",
              "Short-term commitment",
              "No market risk",
              "Automatic renewal options",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Balanced",
            title: "Premium Money Market",
            iconClass: "fa-money-bill-wave",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "APY", value: "4.50%" }, { label: "MINIMUM", value: "$25k" }],
            features: [
              "Check-writing privileges",
              "Debit card access",
              "Tiered interest rates",
              "Perfect for emergency funds",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      studentLoanRefi: {
        name: "Student Loan Refinance",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479781/Loans_How_to_refinance_your_student_loans_in_5_steps_fosnuh.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479140/GettyImages-2194268868_Feature-Single-R_zmffb8.webp",
        },
        vanillaHeroTitle: "Simplify your student debt.",
        vanillaHeroSubtext:
          "Lower your interest rate and combine multiple student loans into one easy monthly payment so you can reach your goals faster.",
        userIntentString: "I want to consolidate my student loans to lower my monthly payment.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three refinance structures to compare—starting rates; a specialist walks through eligibility and savings.",
        adaptiveOverlayTitle: "Student loan refinance options",
        adaptiveOverlaySubtitle:
          "Compare shorter fixed terms, balanced repayment, and variable-rate paths with a lending specialist.",
        adaptiveFooterNote: "Retail Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can finalize your request.",
        homeMarketInsights: {
          sectionSubtitle:
            "Debt management and lifestyle finance.",
          cards: [
            {
              eyebrow: "Travel rewards",
              title: "Travel credit card value and redemption planning",
              body: "The beach travel card image supports this topic on reward design and card value by travel frequency.",
            },
            {
              eyebrow: "Retirement",
              title: "Retirement planning through a family lens",
              body: "The grandparent reading image matches this topic on long-term planning and household priorities.",
            },
            {
              eyebrow: "Auto lending",
              title: "Auto loan planning before major purchases",
              body: "The driver-with-keys image supports this topic on loan setup, payment structure, and purchase timing.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Refinance strategy",
              title: "Student loan refinance steps and calculator planning",
              body: "The student loan calculator image supports this topic on term comparison, rates, and projected payment changes.",
            },
            {
              eyebrow: "Career growth",
              title: "Balancing loan repayment with small business goals",
              body: "The woman opening her business image matches this cross-sell topic on cash flow choices during growth.",
            },
            {
              eyebrow: "Student life",
              title: "Repayment planning for recent graduates",
              body: "The students in a coffee shop image supports this topic on payment flexibility and early-career budget stability.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(415) 234-5678",
          company: "Acme Corp",
          zipCode: "94105",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Fast Payoff",
            title: "5-Year Fixed",
            iconClass: "fa-graduation-cap",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "APR", value: "4.99%" }, { label: "TERM", value: "60 Mo" }],
            features: [
              "Lowest interest rate available",
              "Get out of debt faster",
              "Fixed predictable payments",
              "0.25% AutoPay discount",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Best Match",
            title: "10-Year Fixed",
            iconClass: "fa-graduation-cap",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "APR", value: "5.50%" }, { label: "TERM", value: "120 Mo" }],
            features: [
              "Balanced monthly payments",
              "Standard repayment timeline",
              "Consolidate federal and private",
              "No origination fees",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Flexible",
            title: "7-Year Variable",
            iconClass: "fa-graduation-cap",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "EST. APR", value: "4.75%" }, { label: "CAP", value: "8.95%" }],
            features: [
              "Lower starting interest rate",
              "Rate capped for your protection",
              "Ideal if paying off aggressively",
              "Release co-signer after 24 months",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
    },
    warmInsights: [
      {
        image:
          "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Saving",
        title: "Build savings habits that stick",
        body: "Automatic transfers, clear goals, and the right account mix make progress steady—small steps beat an all-or-nothing approach.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Credit cards",
        title: "Choose rewards that match how you spend",
        body: "Travel points, cash back, or a low-rate card each fit different habits. Comparing fees and perks helps you earn more on purchases you already make.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Investing",
        title: "How to think about IRA investments",
        body: "Time horizon, diversification, and comfort with volatility usually matter more than timing the market—a disciplined plan supports long-term goals.",
      },
    ],
  },
  commercialBanking: {
    coldHeroEyebrow: "Business banking reimagined",
    coldHeroHeading: "Enterprise lending, treasury, and advisory—all in one platform.",
    coldHeroParagraph1: "From credit facilities and cash management to international expansion, ${brandName} partners with growing businesses.",
    coldHeroParagraph2: "Complex needs. Clear solutions. Explore how ${brandName} Commercial Banking brings efficiency to corporate finance.",
    homepageCtaText: "View Lending Solutions",
    homeMarketInsights: {
      sectionSubtitle:
        "Themes for treasury, credit, and risk—informational only, not advice.",
      cards: [
        {
          eyebrow: "Cash management",
          title: "Liquidity that supports growth",
          body: "Clear visibility into receivables, payables, and idle balances helps finance teams fund payroll and capex without over-relying on emergency draws.",
        },
        {
          eyebrow: "Credit",
          title: "Term debt vs. a revolving line",
          body: "Match the facility to the use case: term loans for long-lived assets, lines for seasonal working capital—so pricing and covenants fit how cash actually moves.",
        },
        {
          eyebrow: "Risk",
          title: "Insurance as part of the balance sheet",
          body: "Property, liability, and specialty coverages can protect earnings when operations scale—worth revisiting as revenue mix and vendors change.",
        },
      ],
    },
    categoryPage: {
      heroBgImage:
        "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=2400&q=80",
      catHeroTitle: "Enterprise Commercial Banking",
      catHeroSubtitle: "Strategic treasury and lending solutions to scale your operations.",
      marketInsightsIntro:
        "Practical perspectives for finance and operations leaders. For guidance tailored to ${company}, continue in chat with Penny—your ${brandName} assistant.",
      services: [
        {
          iconClass: "fa-money-bill-transfer",
          title: "Treasury Management",
          description: "Optimize liquidity with advanced receivables and payables",
        },
        {
          iconClass: "fa-handshake",
          title: "Commercial Lending",
          description: "Lines of credit and equipment financing",
        },
        {
          iconClass: "fa-chart-line",
          title: "Capital Markets",
          description: "Syndications, FX, and interest rate risk management",
        },
      ],
      whyChooseUsTitle: "Dedicated Industry Expertise",
      whyChooseUsText:
        "You aren't just getting a bank; you are getting a strategic partner. Our relationship managers specialize in your exact vertical, from manufacturing to healthcare.",
      whyChooseUsImage:
        "https://images.unsplash.com/photo-1560179707-f14e90ef3623?auto=format&fit=crop&w=1200&q=80",
      article1Title: "Interest rates and middle-market borrowing: what to watch",
      article2Title: "Fraud prevention: why positive pay still matters",
    },
    useCases: {
      treasuryServices: {
        name: "Treasury & cash management",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482481/What-is-Treasury-Management_ygnigo.jpg",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481597/20190731_WeWork_SonyCenter_Berlin_008_v1_gbyy1w.webp",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481684/istockphoto-658610090-612x612_gxlzth.jpg",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481868/360_F_283437738_PUdyvxvDJcvplpRu587FYqz9cyrH1IUG_gjk00t.jpg",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482046/managersbusiness_ntnvs5.jpg",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482724/calculator-1516869_1920_ipeyrd.webp",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774483257/Zz1kNGM2Yjk2NDNmNzcxMWVkYTgwZDkyZTAzNTEyNDM1Mw_c0icrz.png",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482228/SOSB0324009_1560x880_desktop_vpn0nd.jpg",
        },
        vanillaHeroTitle: "Cash flow you can see and steer.",
        vanillaHeroSubtext:
          "Payables, receivables, and liquidity tools that help small businesses fund payroll, vendors, and growth with fewer surprises.",
        userIntentString: "I want better payables, receivables, and cash visibility for my business.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three treasury starting points many small businesses review with their relationship team—compare flows, then continue in chat.",
        adaptiveOverlayTitle: "Treasury & cash management options",
        adaptiveOverlaySubtitle:
          "Review payables, receivables, and liquidity snapshots below, then connect with a specialist for your workflow.",
        adaptiveFooterNote: "Commercial Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details for a specialist callback.",
        homeMarketInsights: {
          sectionSubtitle:
            "Treasury and operations insights.",
          cards: [
            {
              eyebrow: "Corporate cards",
              title: "Corporate card controls for client and travel spend",
              body: "The image of a business dinner payment supports this card-focused topic: spend visibility, policy controls, and reconciliation discipline.",
            },
            {
              eyebrow: "Commercial real estate",
              title: "Financing and cash planning for commercial property needs",
              body: "The modern office building visual reflects this CRE theme and highlights how property costs affect liquidity planning.",
            },
            {
              eyebrow: "Treasury operations",
              title: "How finance managers use dashboards to monitor cash position",
              body: "The manager-at-laptop image supports this treasury operations topic: daily visibility across balances, inflows, and outflows.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Working capital",
              title: "Working capital planning in practice",
              body: "The close-up of a spreadsheet and calculator supports this working-capital note: tighten forecasting, payment timing, and liquidity planning.",
            },
            {
              eyebrow: "Payments",
              title: "ACH transfers with stronger controls",
              body: "The digital money-transfer graphic matches your ACH guide note and reinforces setup, approval routing, and reconciliation controls.",
            },
            {
              eyebrow: "Growth",
              title: "Treasury support for growth moments",
              body: "The image of two executives shaking hands reflects your business-growth note and highlights treasury readiness for expansion decisions.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(617) 555-0140",
          company: "Acme Corp",
          zipCode: "02110",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Payables",
            title: "Business Payables Hub",
            iconClass: "fa-money-bill-transfer",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "CHANNELS", value: "ACH + wire" }, { label: "CONTROLS", value: "Dual approval" }],
            features: [
              "Centralize vendor payments",
              "Positive pay for checks",
              "Scheduled releases",
              "Audit-friendly reporting",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Receivables",
            title: "Receivables Acceleration",
            iconClass: "fa-arrow-trend-up",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "DEPOSITS", value: "Same day" }, { label: "MATCHING", value: "Auto" }],
            features: [
              "Faster deposit posting",
              "Remittance detail capture",
              "Receivables reporting",
              "Works with common accounting tools",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Liquidity",
            title: "Liquidity & reporting snapshot",
            iconClass: "fa-chart-line",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "VIEW", value: "Multi-acct" }, { label: "ALERTS", value: "Configurable" }],
            features: [
              "Cash position visibility",
              "Forecast-friendly exports",
              "Fraud monitoring hooks",
              "Scales as accounts grow",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      smallBusinessTermLoan: {
        name: "Small business term loan",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481597/20190731_WeWork_SonyCenter_Berlin_008_v1_gbyy1w.webp",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481868/360_F_283437738_PUdyvxvDJcvplpRu587FYqz9cyrH1IUG_gjk00t.jpg",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482228/SOSB0324009_1560x880_desktop_vpn0nd.jpg",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481684/istockphoto-658610090-612x612_gxlzth.jpg",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482800/AdobeStock_83752801-700x467_uih0vk.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482046/managersbusiness_ntnvs5.jpg",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482925/industrial-oven_ywbhrr.jpg",
        },
        vanillaHeroTitle: "Borrow for the next chapter of your business.",
        vanillaHeroSubtext:
          "Fixed-term financing can fund expansion, equipment, or one-time needs with predictable payments—your team can help size the right structure.",
        userIntentString: "I need a small business term loan for expansion.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Below are three illustrative term structures to compare—rates and terms are illustrative; discuss specifics with lending.",
        adaptiveOverlayTitle: "Term loan structures to review",
        adaptiveOverlaySubtitle:
          "Compare shorter payoff, balanced term, and longer amortization—then continue with your relationship manager.",
        adaptiveFooterNote: "Commercial Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details for a specialist callback.",
        homeMarketInsights: {
          sectionSubtitle:
            "Business lending resources.",
          cards: [
            {
              eyebrow: "Commercial real estate",
              title: "Commercial property expansion and term-loan fit",
              body: "The office-building image supports this expansion topic by framing how term debt can align with longer-lived property investments.",
            },
            {
              eyebrow: "Business growth",
              title: "Growth planning through partnership and capital access",
              body: "The executive handshake visual reflects your growth note and introduces financing as a tool for expansion planning.",
            },
            {
              eyebrow: "Corporate cards",
              title: "Managing card-based operating expenses while scaling",
              body: "The business payment image supports this topic by connecting spend controls to broader borrowing and cash-flow planning.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Loan readiness",
              title: "First business loan readiness checklist",
              body: "The step-by-step document visual aligns to your '5 steps' note and frames documentation and underwriting preparation clearly.",
            },
            {
              eyebrow: "Operations",
              title: "Operating discipline after funding",
              body: "The business manager smiling at a laptop mirrors your note and supports a conversation about tracking performance after capital is deployed.",
            },
            {
              eyebrow: "Expansion",
              title: "Expansion capital in action",
              body: "The bakery owner showing a new commercial oven matches your success-story note and illustrates capital tied to visible capacity upgrades.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(617) 555-0140",
          company: "Acme Corp",
          zipCode: "02110",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Faster payoff",
            title: "36-Month Term Loan",
            iconClass: "fa-handshake",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "PAYMENT", value: "Higher" }, { label: "INTEREST", value: "Lower total" }],
            features: [
              "Retire debt sooner",
              "Less total interest vs longer terms",
              "Good for near-term projects",
              "Fixed payment schedule",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Balanced",
            title: "60-Month Term Loan",
            iconClass: "fa-handshake",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "PAYMENT", value: "Moderate" }, { label: "STRUCTURE", value: "Fixed" }],
            features: [
              "Balanced monthly cash flow",
              "Suited to expansion or refinance",
              "Dedicated closing support",
              "Covenant discussion with your team",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Lower payment",
            title: "84-Month Term Loan",
            iconClass: "fa-handshake",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "PAYMENT", value: "Lower" }, { label: "USE CASE", value: "Capex" }],
            features: [
              "Smaller monthly obligation",
              "Pairs with longer-lived assets",
              "Preserves near-term liquidity",
              "Subject to credit approval",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      businessLineOfCredit: {
        name: "Business line of credit",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482364/istockphoto-1304746031-612x612_ccrxbd.jpg",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481597/20190731_WeWork_SonyCenter_Berlin_008_v1_gbyy1w.webp",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482046/managersbusiness_ntnvs5.jpg",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481684/istockphoto-658610090-612x612_gxlzth.jpg",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481868/360_F_283437738_PUdyvxvDJcvplpRu587FYqz9cyrH1IUG_gjk00t.jpg",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482228/SOSB0324009_1560x880_desktop_vpn0nd.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774483106/what-is-a-small-business-loan-sba-7a-504-live-oak-bank-blog_eodueq.webp",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774483004/farmer-using-laptop-in-the-farm-business-NQQUMHA-1024x688_vaerve.jpg",
        },
        vanillaHeroTitle: "Flexible credit for everyday operations.",
        vanillaHeroSubtext:
          "A revolving line helps cover payroll, inventory, and seasonal swings—you draw when you need it and pay interest on what you use.",
        userIntentString: "I need a business line of credit for working capital.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three line-of-credit profiles to compare—limits and pricing are illustrative for your lending conversation.",
        adaptiveOverlayTitle: "Line of credit options",
        adaptiveOverlaySubtitle:
          "Compare capacity, access, and covenant posture with your relationship team.",
        adaptiveFooterNote: "Commercial Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details for a specialist callback.",
        homeMarketInsights: {
          sectionSubtitle:
            "Working capital management.",
          cards: [
            {
              eyebrow: "Business operations",
              title: "Cash oversight for day-to-day operating decisions",
              body: "The manager-at-laptop image supports this operations note: balancing payables, receivables, and near-term liquidity needs.",
            },
            {
              eyebrow: "Corporate cards",
              title: "Card spend governance as part of working-capital management",
              body: "The payment-at-dinner visual reflects this control topic and highlights policy, approvals, and expense visibility.",
            },
            {
              eyebrow: "Commercial real estate",
              title: "Property commitments and their impact on credit capacity",
              body: "The office-building image supports this planning theme by linking occupancy costs with line-of-credit flexibility.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Growth",
              title: "Growth planning with revolving credit",
              body: "The executive handshake image reflects your growth note and supports planning line usage around expansion timing and execution.",
            },
            {
              eyebrow: "Cash flow",
              title: "Managing seasonal cash flow gaps",
              body: "The seasonal cash-flow article visual matches your note and reinforces draw timing, repayment cadence, and smoother operating cycles.",
            },
            {
              eyebrow: "Line utilization",
              title: "How to use a revolving line of credit in day-to-day operations",
              body: "The business-owner-at-laptop image aligns with your revolving-credit note and highlights practical short-term uses with disciplined paydown.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(617) 555-0140",
          company: "Acme Corp",
          zipCode: "02110",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Starter",
            title: "Secured Business Line",
            iconClass: "fa-chart-line",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "CAPACITY", value: "Up to $250k" }, { label: "ACCESS", value: "Online" }],
            features: [
              "Collateral-backed capacity",
              "Lower pricing vs unsecured",
              "Renewal subject to review",
              "Good for predictable draws",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Growth",
            title: "Revolving Operating Line",
            iconClass: "fa-chart-line",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "CAPACITY", value: "Up to $750k" }, { label: "ACCESS", value: "Same-day" }],
            features: [
              "Revolving capacity for payroll",
              "Cash sweep integration",
              "Interest on outstanding balance only",
              "Covenant package tailored in underwriting",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Scale",
            title: "Asset-Based Line",
            iconClass: "fa-chart-line",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "CAPACITY", value: "Formula" }, { label: "COLLATERAL", value: "A/R" }],
            features: [
              "Borrowing base tied to receivables",
              "Supports faster growth cycles",
              "Monitoring and reporting cadence",
              "Specialist onboarding",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      equipmentFinance: {
        name: "Business equipment financing",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482562/HanmiBank-Equipment-Leasing_pgktwd.jpg",
          coldHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481597/20190731_WeWork_SonyCenter_Berlin_008_v1_gbyy1w.webp",
          insight1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482228/SOSB0324009_1560x880_desktop_vpn0nd.jpg",
          insight2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482046/managersbusiness_ntnvs5.jpg",
          insight3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481684/istockphoto-658610090-612x612_gxlzth.jpg",
          warmTile1:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482605/29307149891_b1b36235fb_b_pbmuvy.jpg",
          warmTile2:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774483177/what-is-equipment-leasing_j6b3db.jpg",
          warmTile3:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481868/360_F_283437738_PUdyvxvDJcvplpRu587FYqz9cyrH1IUG_gjk00t.jpg",
        },
        vanillaHeroTitle: "Equip your business without draining cash.",
        vanillaHeroSubtext:
          "Finance vehicles, machinery, or technology with structures aligned to how long the asset serves your operations.",
        userIntentString: "I need financing for business equipment or vehicles.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three equipment financing starting points to review—starting terms; your specialist can match structure to asset life.",
        adaptiveOverlayTitle: "Equipment financing options",
        adaptiveOverlaySubtitle:
          "Compare standard, accelerated, and flexible structures with your lending team.",
        adaptiveFooterNote: "Commercial Banking · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details for a specialist callback.",
        homeMarketInsights: {
          sectionSubtitle:
            "Equipment financing and capital planning.",
          cards: [
            {
              eyebrow: "Business growth",
              title: "Expansion timing and equipment investment priorities",
              body: "The executive handshake visual supports this growth note and frames equipment financing as part of broader scaling plans.",
            },
            {
              eyebrow: "Operations",
              title: "Operational readiness before major equipment purchases",
              body: "The manager-at-laptop image reflects this planning topic: cash visibility, utilization forecasts, and implementation sequencing.",
            },
            {
              eyebrow: "Corporate cards",
              title: "Short-term spend controls around capital projects",
              body: "The business payment image supports this controls topic and highlights card policy discipline during project rollouts.",
            },
          ],
        },
        warmMarketInsights: {
          cards: [
            {
              eyebrow: "Tax strategy",
              title: "Section 179 deduction considerations for heavy machinery",
              body: "The tractor-in-field image directly reflects your Section 179 note and supports timing and eligibility discussions with tax advisors.",
            },
            {
              eyebrow: "Structure",
              title: "Lease versus buy equipment analysis",
              body: "The lease-versus-buy analysis visual matches your note and supports a clear comparison of ownership, flexibility, and lifecycle cost.",
            },
            {
              eyebrow: "Asset planning",
              title: "Equipment financing in the context of broader facilities planning",
              body: "The modern office-building image ties to your commercial real-estate note and connects equipment decisions to broader capital planning.",
            },
          ],
        },
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(617) 555-0140",
          company: "Acme Corp",
          zipCode: "02110",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Capex",
            title: "Equipment term financing",
            iconClass: "fa-truck",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "FINANCING", value: "Up to 100%" }, { label: "TERMS", value: "Flexible" }],
            features: [
              "Preserve working capital",
              "Bundle equipment and soft costs",
              "Scheduled draws",
              "Amortization aligned to asset life",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Vehicles",
            title: "Fleet & vehicle program",
            iconClass: "fa-truck",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "STRUCTURE", value: "Fixed" }, { label: "TITLE", value: "Lien" }],
            features: [
              "Multiple unit scheduling",
              "End-of-term options to discuss",
              "Insurance requirements apply",
              "Relationship manager coordination",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Tech",
            title: "Technology & machinery lease-style",
            iconClass: "fa-cogs",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "UPGRADE", value: "Optional" }, { label: "TERM", value: "36–60 mo" }],
            features: [
              "Technology refresh flexibility",
              "Predictable payments",
              "End-of-term choices",
              "Rates subject to approval",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
    },
    warmInsights: [
      {
        image:
          "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Cash management",
        title: "Liquidity that supports growth",
        body: "Clear visibility into receivables, payables, and idle balances helps finance teams fund payroll and capex without over-relying on emergency draws.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1565514020179-026b92b84bb6?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Credit",
        title: "Term debt vs. a revolving line",
        body: "Match the facility to the use case: term loans for long-lived assets, lines for seasonal working capital—so pricing and covenants fit how cash actually moves.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Risk",
        title: "Insurance as part of the balance sheet",
        body: "Property, liability, and specialty coverages can protect earnings when operations scale—worth revisiting as revenue mix and vendors change.",
      },
    ],
  },
  wealthManagement: {
    coldHeroEyebrow: "Legacy. Growth. Peace of mind.",
    coldHeroHeading: "Private wealth strategies that evolve with you.",
    coldHeroParagraph1: "Estate planning, tax optimization, and investment management—${brandName} provides personalized guidance for high-net-worth families.",
    coldHeroParagraph2: "Your goals, your timeline, your legacy. See how ${brandName} Wealth Management helps protect and grow what matters most.",
    homepageCtaText: "Explore Wealth Strategies",
    homeMarketInsights: {
      sectionSubtitle:
        "Planning-focused perspectives for families and business owners—informational only.",
      cards: [
        {
          eyebrow: "Planning",
          title: "Financial planning fundamentals to revisit each year",
          body: "Goals, cash flow, and risk tolerance should stay in sync as life changes—regular check-ins beat a set-and-forget plan.",
        },
        {
          eyebrow: "Retirement",
          title: "Balancing growth and income before major milestones",
          body: "As timelines shorten, many investors shift toward steadier income and tax-aware withdrawals—without abandoning growth entirely.",
        },
        {
          eyebrow: "Legacy",
          title: "Estate and trust topics worth discussing early",
          body: "Clarity on titles, beneficiaries, and successor roles can prevent surprises for heirs and simplify coordination with your advisory team.",
        },
      ],
    },
    categoryPage: {
      heroBgImage:
        "https://images.unsplash.com/photo-1556761175-5973dc0f32d7?auto=format&fit=crop&w=2400&q=80",
      catHeroTitle: "Private Wealth Services",
      catHeroSubtitle: "Protecting your legacy and optimizing your financial future.",
      marketInsightsIntro:
        "Ideas spanning planning, retirement, and legacy. When you want a personalized view, continue in chat with Penny—your ${brandName} assistant.",
      services: [
        {
          iconClass: "fa-chart-pie",
          title: "Investment Management",
          description: "Discretionary portfolios and alternative assets",
        },
        {
          iconClass: "fa-scroll",
          title: "Trust & Estate",
          description: "Multi-generational wealth transfer structuring",
        },
        {
          iconClass: "fa-calculator",
          title: "Tax Optimization",
          description: "Tax-loss harvesting and philanthropic planning",
        },
      ],
      whyChooseUsTitle: "A Fiduciary Standard of Care",
      whyChooseUsText:
        "We operate with complete transparency. Our advisory teams act strictly as fiduciaries, ensuring every recommendation is made solely in your best interest, free from proprietary conflicts.",
      whyChooseUsImage:
        "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=1200&q=80",
      article1Title: "Estate tax changes on the horizon: planning conversations to start now",
      article2Title: "Private markets in a diversified portfolio: fit and trade-offs",
    },
    useCases: {
      retirementPlanning: {
        name: "Retirement planning",
        heroAssets: {
          warmHero:
            "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?auto=format&fit=crop&w=1600&q=80",
          coldHero:
            "https://images.unsplash.com/photo-1556761175-5973dc0f32d7?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1554200876-56c2f25224d81?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Retirement on your terms, step by step.",
        vanillaHeroSubtext:
          "Savings rate, tax-aware accounts, and drawdown timing work best when they match your horizon—your advisor can help stress-test the plan.",
        userIntentString: "I want help planning for retirement.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three retirement planning starting points to review with your advisor—these are starting points for discussion.",
        adaptiveOverlayTitle: "Retirement planning paths",
        adaptiveOverlaySubtitle:
          "Compare accumulation focus, balanced growth and income, and conservative income—then continue in chat or with your team.",
        adaptiveFooterNote: "Wealth Management · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details to schedule time with an advisor.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(212) 555-0198",
          company: "Acme Corp",
          zipCode: "10012",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Growth",
            title: "Growth-oriented glide path",
            iconClass: "fa-chart-line",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "HORIZON", value: "15+ yr" }, { label: "RISK", value: "Higher" }],
            features: [
              "Emphasis on long-term compounding",
              "Periodic rebalancing discussion",
              "Tax location awareness",
              "Rates subject to approval",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Balanced",
            title: "Balanced retirement portfolio",
            iconClass: "fa-scale-balanced",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "MIX", value: "60/40" }, { label: "REVIEW", value: "Annual" }],
            features: [
              "Growth with volatility moderation",
              "Cash-flow planning checkpoints",
              "Employer plan coordination",
              "Advisor-led adjustments",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Income",
            title: "Income-first approach",
            iconClass: "fa-piggy-bank",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "FOCUS", value: "Cash flow" }, { label: "DRAWDOWN", value: "Planned" }],
            features: [
              "Steadier distribution planning",
              "Longevity and healthcare considerations",
              "Tax-aware withdrawal order",
              "Not a product recommendation",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      educationSavings529: {
        name: "529 & education savings",
        heroAssets: {
          warmHero:
            "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=1600&q=80",
          coldHero:
            "https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1588072432836-1004d9785a72?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Save for school with a clear plan.",
        vanillaHeroSubtext:
          "Education accounts can pair discipline with flexibility—your advisor can explain trade-offs across account types and timelines.",
        userIntentString: "I want to start saving for a child's education.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Below are three education-savings profiles to discuss—rules vary by state and plan.",
        adaptiveOverlayTitle: "Education savings options",
        adaptiveOverlaySubtitle:
          "Compare age-based, balanced, and stable allocation illustrations with your advisor.",
        adaptiveFooterNote: "Wealth Management · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details to schedule time with an advisor.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(212) 555-0198",
          company: "Acme Corp",
          zipCode: "10012",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Long horizon",
            title: "Age-based glide path",
            iconClass: "fa-graduation-cap",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "STYLE", value: "Auto shift" }, { label: "HORIZON", value: "10+ yr" }],
            features: [
              "Equity tilt when young",
              "Gradual risk reduction",
              "Good for “set and review” savers",
              "Plan features vary—ask your advisor",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Balanced",
            title: "Balanced education portfolio",
            iconClass: "fa-graduation-cap",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "MIX", value: "Moderate" }, { label: "REVIEW", value: "Yearly" }],
            features: [
              "Stocks and bonds blend",
              "Flexible for K–12 or college goals",
              "Contribution planning conversation",
              "Rates vary by property",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Near term",
            title: "Capital preservation tilt",
            iconClass: "fa-graduation-cap",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "VOLATILITY", value: "Lower" }, { label: "USE", value: "Soon" }],
            features: [
              "Emphasis on stability near enrollment",
              "Spending flexibility discussion",
              "Gift and tax topics with counsel",
              "Not tax or legal advice",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      iraInvesting: {
        name: "IRA investments",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          coldHero:
            "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "IRAs that match how you save.",
        vanillaHeroSubtext:
          "Traditional and Roth trade-offs, contribution limits, and investment mix are easier to compare with a simple framework—your advisor fills in the details.",
        userIntentString: "I want to invest through an IRA.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three IRA investment approaches to review—starting points; eligibility and limits change over time.",
        adaptiveOverlayTitle: "IRA investment profiles",
        adaptiveOverlaySubtitle:
          "Compare index-oriented, actively managed, and balanced illustrations with your advisor.",
        adaptiveFooterNote: "Wealth Management · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details to schedule time with an advisor.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(212) 555-0198",
          company: "Acme Corp",
          zipCode: "10012",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Simple",
            title: "Core index allocation",
            iconClass: "fa-layer-group",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "STYLE", value: "Broad market" }, { label: "FEES", value: "0.45%" }],
            features: [
              "US and international sleeves",
              "Rebalancing discipline",
              "Straightforward reporting",
              "Not a recommendation",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Advisory",
            title: "Advisory mutual fund lineup",
            iconClass: "fa-chart-pie",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "SUPPORT", value: "Ongoing" }, { label: "MIX", value: "Diversified" }],
            features: [
              "Fund selection support",
              "Risk and goal check-ins",
              "Tax-aware placement where appropriate",
              "Demo experience",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Stability",
            title: "Conservative balanced IRA",
            iconClass: "fa-shield-halved",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "BONDS", value: "Higher %" }, { label: "VOL", value: "Lower" }],
            features: [
              "Emphasis on downside moderation",
              "Shorter horizon friendly",
              "Cash needs discussion",
              "Advisor-guided",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      estatePlanning: {
        name: "Estate & trust planning",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231728/Rollover_IRAs_qmvvmo.webp",
          coldHero:
            "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Private wealth, disciplined planning.",
        vanillaHeroSubtext:
          "Estate, tax-aware investing, and portfolio management aligned to your objectives—your attorney and advisor should coordinate on documents and titles.",
        userIntentString: "I need help with tax optimization and estate planning.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are estate and trust topics many families review next—nothing here replaces personalized legal or tax advice.",
        adaptiveOverlayTitle: "Wealth strategies for review",
        adaptiveOverlaySubtitle:
          "Estate planning, tax optimization, and portfolio support—discuss with your advisor.",
        adaptiveFooterNote: "Wealth Management · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details to schedule time with an advisor.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(212) 555-0198",
          company: "Acme Corp",
          zipCode: "10012",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Tax",
            title: "Tax-aware planning layer",
            iconClass: "fa-calculator",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "FOCUS", value: "Coordination" }, { label: "REVIEW", value: "Annual" }],
            features: [
              "Gain and loss awareness",
              "Charitable giving timing",
              "Withholding and estimates discussion",
              "Work with your CPA",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Estate",
            title: "Revocable living trust framework",
            iconClass: "fa-scroll",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "REVIEW", value: "Annual" }, { label: "SETUP", value: "Guided" }],
            features: [
              "Pour-over will coordination",
              "Successor trustee roles",
              "Probate avoidance goals",
              "Attorney drafts documents",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Legacy",
            title: "Heir and succession clarity",
            iconClass: "fa-diagram-project",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "HORIZON", value: "Multi-gen" }, { label: "OUTPUT", value: "Summary" }],
            features: [
              "Beneficiary consistency check",
              "Family meeting talking points",
              "Business succession hooks",
              "Scenarios for discussion",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
    },
    warmInsights: [
      {
        image:
          "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Planning",
        title: "Financial planning fundamentals to revisit each year",
        body: "Goals, cash flow, and risk tolerance should stay in sync as life changes—regular check-ins beat a set-and-forget plan.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Retirement",
        title: "Balancing growth and income before major milestones",
        body: "As timelines shorten, many investors shift toward steadier income and tax-aware withdrawals—without abandoning growth entirely.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Legacy",
        title: "Estate and trust topics worth discussing early",
        body: "Clarity on titles, beneficiaries, and successor roles can prevent surprises for heirs and simplify coordination with your advisory team.",
      },
    ],
  },
  assetManagement: {
    coldHeroEyebrow: "Institutional excellence",
    coldHeroHeading: "Asset management solutions built for scale and performance.",
    coldHeroParagraph1: "From pension funds to endowments, ${brandName} delivers research-driven strategies and rigorous risk management.",
    coldHeroParagraph2: "Institutional discipline. Forward-thinking approach. Discover how ${brandName} Asset Management drives results for complex portfolios.",
    homepageCtaText: "View Institutional Funds",
    homeMarketInsights: {
      sectionSubtitle:
        "Research-led themes for institutional investors—informational only.",
      cards: [
        {
          eyebrow: "Markets",
          title: "Diversification when correlations move together",
          body: "When asset classes sync up, intentional sleeves—by region, factor, or duration—can still spread risk across scenarios, not just tickers.",
        },
        {
          eyebrow: "Process",
          title: "What fundamental research adds in noisy markets",
          body: "Disciplined underwriting and scenario analysis help teams separate narrative from cash-flow durability before sizing positions.",
        },
        {
          eyebrow: "Sustainable",
          title: "ESG integration beyond the headline score",
          body: "Materiality, engagement, and reporting standards differ widely—useful analysis focuses on what affects long-term value, not labels alone.",
        },
      ],
    },
    categoryPage: {
      heroBgImage:
        "https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=2400&q=80",
      catHeroTitle: "Institutional Asset Management",
      catHeroSubtitle: "High-conviction strategies driven by fundamental research.",
      marketInsightsIntro:
        "Themes for mandates and consultants. For materials aligned to your policy, continue in chat with Penny—your ${brandName} assistant.",
      services: [
        {
          iconClass: "fa-globe",
          title: "Global Equities",
          description: "Active management across emerging and developed markets",
        },
        {
          iconClass: "fa-scale-balanced",
          title: "Fixed Income",
          description: "Core, high yield, and municipal bond strategies",
        },
        {
          iconClass: "fa-leaf",
          title: "Sustainable Investing",
          description: "Deep ESG integration and active engagement",
        },
      ],
      whyChooseUsTitle: "Proprietary Research Engine",
      whyChooseUsText:
        "Our advantage is our perspective. With over 200 analysts globally, our bottom-up research uncovers opportunities that passive strategies and algorithmic models simply miss.",
      whyChooseUsImage:
        "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=1200&q=80",
      article1Title: "Duration and rates: stress tests for core fixed income",
      article2Title: "ESG integration and alpha: what engagement can add",
    },
    useCases: {
      globalEquitiesMandate: {
        name: "Global equities mandate",
        heroAssets: {
          warmHero:
            "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=1600&q=80",
          coldHero:
            "https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1533750349088-cd871a92f312?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Global equities for institutional sleeves.",
        vanillaHeroSubtext:
          "Compare regional emphasis, active versus indexed approaches, and risk budgets with your consultant before sizing a mandate.",
        userIntentString: "We need global equity exposure for our plan.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Below are three global equity mandate illustrations—illustrative metrics; your consultant can align them to policy and benchmark.",
        adaptiveOverlayTitle: "Equity mandate profiles",
        adaptiveOverlaySubtitle:
          "Review developed international tilt, broad global, and emerging-markets allocation sketches.",
        adaptiveFooterNote: "Asset Management · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can send the right prospectus packet.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(312) 555-0142",
          company: "Acme Corp",
          zipCode: "60606",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Developed",
            title: "International developed sleeve",
            iconClass: "fa-globe",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "STYLE", value: "Active" }, { label: "REGION", value: "Developed Intl" }],
            features: [
              "Bottom-up stock selection story",
              "Currency policy discussion",
              "Benchmark-relative risk framing",
              "Policy-aligned positioning",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Global",
            title: "Broad global core equity",
            iconClass: "fa-globe",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "STYLE", value: "Core" }, { label: "BENCH", value: "Global benchmark" }],
            features: [
              "US and non-US blend",
              "Sector and factor controls",
              "Liquidity suited to plans",
              "Consultant due diligence",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Emerging",
            title: "Emerging markets satellite",
            iconClass: "fa-chart-line",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "ROLE", value: "Satellite" }, { label: "VOL", value: "Higher" }],
            features: [
              "Smaller policy weight typical",
              "Liquidity and capacity checks",
              "Governance considerations",
              "Not a recommendation",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      coreFixedIncomeMandate: {
        name: "Core fixed income",
        heroAssets: {
          warmHero:
            "https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=1600&q=80",
          coldHero:
            "https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Fixed income that fits the liability picture.",
        vanillaHeroSubtext:
          "Core, short duration, and core-plus sketches help teams talk about credit quality, duration, and income needs with consultants.",
        userIntentString: "We need a core bond mandate for stability.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three core fixed income illustrations—yields and durations are demo placeholders for policy discussion.",
        adaptiveOverlayTitle: "Fixed income mandate profiles",
        adaptiveOverlaySubtitle:
          "Compare short government-biased, core investment grade, and core-plus sketches.",
        adaptiveFooterNote: "Asset Management · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can send the right prospectus packet.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(312) 555-0142",
          company: "Acme Corp",
          zipCode: "60606",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Stability",
            title: "Short duration government tilt",
            iconClass: "fa-scale-balanced",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "DURATION", value: "2-3 yrs" }, { label: "CREDIT", value: "Gov bias" }],
            features: [
              "Lower rate sensitivity story",
              "Liquidity emphasis",
              "Capital preservation framing",
              "Estimated metrics",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Core",
            title: "Core investment grade",
            iconClass: "fa-scale-balanced",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "DURATION", value: "Intermed." }, { label: "CREDIT", value: "IG focus" }],
            features: [
              "Corporate and government mix",
              "Benchmark-aware process",
              "Income versus volatility trade-off",
              "Consultant DD",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Plus",
            title: "Core-plus income",
            iconClass: "fa-scale-balanced",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "YIELD", value: "4.5%" }, { label: "RISK", value: "Elevated" }],
            features: [
              "Selective below-IG allowance",
              "Drawdown discussion",
              "Fits some return-seeking sleeves",
              "Not for all policies",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      sustainableInstitutional: {
        name: "Sustainable / ESG mandate",
        heroAssets: {
          warmHero:
            "https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=1600&q=80",
          coldHero:
            "https://images.unsplash.com/photo-1497435334941-636c87ea4eda?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Sustainable mandates, clearly framed.",
        vanillaHeroSubtext:
          "ESG integration, thematic sleeves, and green-bond allocations mean different things—your consultant can map each to policy language.",
        userIntentString: "Show me sustainable investment options.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "You asked about sustainable options—here are three mandate profiles to compare with your consultant; these are starting points.",
        adaptiveOverlayTitle: "Fund profiles for your mandate",
        adaptiveOverlaySubtitle:
          "Review integrated ESG equity, real-assets climate tilt, and green-bond sleeve illustrations.",
        adaptiveFooterNote: "Asset Management · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can send the right prospectus packet.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(312) 555-0142",
          company: "Acme Corp",
          zipCode: "60606",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Equity",
            title: "Global ESG-integrated equity",
            iconClass: "fa-leaf",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "APPROACH", value: "Integration" }, { label: "REPORTING", value: "ESG" }],
            features: [
              "Materiality-focused research story",
              "Engagement where permitted",
              "Benchmark-relative risk",
              "Read prospectus before investing",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Real assets",
            title: "Climate infrastructure sleeve",
            iconClass: "fa-solar-panel",
            metrics: [
              { label: "ROLE", value: "Illiquid" },
              { label: "TERM", value: "Long" },
              { label: "FIT", value: "Satellite" },
            ],
            features: [
              "Renewables and grid themes (illustrative)",
              "Liquidity and capacity constraints",
              "Low correlation story",
              "Due diligence required",
            ],
            bundleText: "",
            ctaLabel: "View materials",
          },
          {
            recommended: false,
            smallTag: "Fixed income",
            title: "Green bond emphasis",
            iconClass: "fa-seedling",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "CREDIT", value: "IG" }, { label: "DURATION", value: "Intermed." }],
            features: [
              "Use-of-proceeds focus in selection",
              "Impact reporting varies by issuer",
              "Fits some liability-aware books",
              "Not a guarantee of impact",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      liquidityInstitutional: {
        name: "Liquidity & cash strategies",
        heroAssets: {
          warmHero:
            "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?auto=format&fit=crop&w=1600&q=80",
          coldHero:
            "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1553729459-efe14ef6055d?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Institutional liquidity, disciplined.",
        vanillaHeroSubtext:
          "Government money market, ultra-short bond, and short-duration sleeves serve different cash roles—policy and prospectuses define the details.",
        userIntentString: "We need a stable place for plan cash balances.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three liquidity sleeve illustrations—stable value and money market rules vary; review with counsel and your consultant.",
        adaptiveOverlayTitle: "Liquidity sleeve comparisons",
        adaptiveOverlaySubtitle:
          "Compare government money market, ultra-short bond, and short-duration credit sketches.",
        adaptiveFooterNote: "Asset Management · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details so we can send the right prospectus packet.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(312) 555-0142",
          company: "Acme Corp",
          zipCode: "60606",
        },
        cards: [
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Cash",
            title: "Government money market",
            iconClass: "fa-coins",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "STABILITY", value: "High" }, { label: "YIELD", value: "Modest" }],
            features: [
              "Same-day liquidity typical",
              "Rule 2a-7 style framing",
              "Fits operational cash",
              "Read fund documents",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Ultra-short",
            title: "Ultra-short bond",
            iconClass: "fa-wave-square",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "DURATION", value: "Very low" }, { label: "YIELD", value: "Step-up" }],
            features: [
              "Slightly more yield than pure cash",
              "Mark-to-market fluctuation possible",
              "Minimum time horizon discussion",
              "Not FDIC insured",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Short IG",
            title: "Short investment grade",
            iconClass: "fa-chart-line",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "CREDIT", value: "IG" }, { label: "VOL", value: "Low–mod" }],
            features: [
              "Income over pure cash",
              "Rate and spread sensitivity",
              "Fits some reserve sleeves",
              "Policy limits apply",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
    },
    warmInsights: [
      {
        image:
          "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Markets",
        title: "Diversification when correlations move together",
        body: "When asset classes sync up, intentional sleeves—by region, factor, or duration—can still spread risk across scenarios, not just tickers.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Process",
        title: "What fundamental research adds in noisy markets",
        body: "Disciplined underwriting and scenario analysis help teams separate narrative from cash-flow durability before sizing positions.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Sustainable",
        title: "ESG integration beyond the headline score",
        body: "Materiality, engagement, and reporting standards differ widely—useful analysis focuses on what affects long-term value, not labels alone.",
      },
    ],
  },
  insurance: {
    coldHeroEyebrow: "Protection. Confidence. Security.",
    coldHeroHeading: "Comprehensive coverage for life's most important moments.",
    coldHeroParagraph1: "Auto, home, life, and umbrella policies—${brandName} Insurance helps you protect what matters most.",
    coldHeroParagraph2: "Peace of mind starts with the right coverage. Explore ${brandName} Insurance solutions designed for your needs.",
    homepageCtaText: "Get a Quote",
    homeMarketInsights: {
      sectionSubtitle:
        "Coverage and protection topics to explore—informational only, not a quote or recommendation.",
      cards: [
        {
          eyebrow: "Home",
          title: "Review replacement cost as values change",
          body: "Construction and material costs move over time; an annual policy check helps limits keep pace so a claim does not fall short of rebuild reality.",
        },
        {
          eyebrow: "Auto",
          title: "Liability limits that match how you drive and what you own",
          body: "Higher limits can matter after a serious accident—especially if you commute often, carry passengers, or have growing assets to protect.",
        },
        {
          eyebrow: "Protection",
          title: "When an umbrella policy is worth a conversation",
          body: "An umbrella can add an extra layer above auto and home liability—useful if you host often, own rental property, or serve on a board.",
        },
      ],
    },
    categoryPage: {
      heroBgImage:
        "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=2400&q=80",
      catHeroTitle: "Personal Insurance Solutions",
      catHeroSubtitle: "Comprehensive coverage for the people and assets that matter most.",
      marketInsightsIntro:
        "Straightforward reads on home, auto, and liability coverage. For options suited to your household, continue in chat with Penny—your ${brandName} assistant.",
      services: [
        {
          iconClass: "fa-car",
          title: "Auto & Vehicle",
          description: "Coverage for cars, motorcycles, and recreational vehicles",
        },
        {
          iconClass: "fa-house-chimney",
          title: "Home & Property",
          description: "Homeowners, renters, and valuable items protection",
        },
        {
          iconClass: "fa-shield-heart",
          title: "Life & Umbrella",
          description: "Term life and extended liability coverage",
        },
      ],
      whyChooseUsTitle: "Seamless, 24/7 Claims Processing",
      whyChooseUsText:
        "When the unexpected happens, we are here. File, track, and resolve claims instantly through our digital portal or speak directly to your dedicated concierge team.",
      whyChooseUsImage:
        "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=1200&q=80",
      article1Title: "Personal umbrella coverage: who it helps most",
      article2Title: "Bundling home and auto: savings and simplicity",
    },
    useCases: {
      auto: {
        name: "Auto insurance",
        heroAssets: {
          warmHero:
            "https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1600&q=80",
          coldHero:
            "https://images.unsplash.com/photo-1449965408861-eb3a11764c7d?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1449965408861-eb3a11764c7d?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1489824904134-891ab64532f1?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Auto coverage that fits how you drive.",
        vanillaHeroSubtext:
          "Limits, deductibles, and add-ons should match your commute, passengers, and assets—compare starting points, then talk to a licensed agent.",
        userIntentString: "I want to review my auto insurance.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three auto coverage tiers to review—a licensed specialist confirms eligibility and final pricing.",
        adaptiveOverlayTitle: "Auto coverage options",
        adaptiveOverlaySubtitle:
          "Compare standard, enhanced liability, and premium roadside bundles with a licensed agent.",
        adaptiveFooterNote: "Insurance · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details to connect with a licensed specialist.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(503) 555-0167",
          company: "Acme Corp",
          zipCode: "97205",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Basic",
            title: "State-aware essentials",
            iconClass: "fa-car",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "LIABILITY", value: "Standard" }, { label: "DED", value: "$750" }],
            features: [
              "Bodily injury and property damage",
              "Uninsured motorist options to discuss",
              "Digital ID cards",
              "Not a quote",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Balanced",
            title: "Higher liability comfort",
            iconClass: "fa-car",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "LIABILITY", value: "Elevated" }, { label: "DED", value: "$500" }],
            features: [
              "Increased liability limits",
              "Rental reimbursement option",
              "Accident forgiveness where available",
              "Licensed agent review",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Premium",
            title: "Roadside & new-car extras",
            iconClass: "fa-car",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "ROADSIDE", value: "Included" }, { label: "GLASS", value: "No deductible" }],
            features: [
              "24/7 roadside and towing",
              "New car replacement discussion",
              "Gap coverage where applicable",
              "For illustration only",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      home: {
        name: "Homeowners / renters",
        heroAssets: {
          warmHero:
            "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=1600&q=80",
          coldHero:
            "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Home protection that keeps pace with value.",
        vanillaHeroSubtext:
          "Replacement cost, deductibles, and riders change as markets move—use these tiers as a conversation starter with a licensed agent.",
        userIntentString: "I need homeowners or renters coverage.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Below are three home policy sketches—illustrative; an agent validates limits, discounts, and exclusions for your address.",
        adaptiveOverlayTitle: "Home and property options",
        adaptiveOverlaySubtitle:
          "Compare core, replacement-cost plus, and high-value home illustrations.",
        adaptiveFooterNote: "Insurance · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details to connect with a licensed specialist.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(503) 555-0167",
          company: "Acme Corp",
          zipCode: "97205",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Core",
            title: "Dwelling essentials",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "FORM", value: "HO-3" }, { label: "DED", value: "$1k" }],
            features: [
              "Dwelling and other structures",
              "Personal property baseline",
              "Loss of use discussion",
              "Renters parallel available",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Replacement",
            title: "Replacement cost emphasis",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "RC", value: "Extended RCV" }, { label: "DED", value: "$1.5k" }],
            features: [
              "Rebuild cost check-ins",
              "Water backup rider option",
              "Scheduled jewelry conversation",
              "Agent verifies details",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "High value",
            title: "Premier home program",
            iconClass: "fa-house-chimney",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "VALUABLES", value: "Scheduled" }, { label: "SERVICE", value: "Concierge" }],
            features: [
              "Higher liability coordination",
              "Flood and quake referrals",
              "Appraisal workflow",
              "Not available everywhere",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      life: {
        name: "Life insurance",
        heroAssets: {
          warmHero:
            "https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=1600&q=80",
          coldHero:
            "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Life coverage sized to your responsibilities.",
        vanillaHeroSubtext:
          "Term lengths and face amounts depend on income replacement, debts, and goals—these are illustrative tiers for agent discussion.",
        userIntentString: "I want term life insurance for my family.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "Here are three term-life illustrations—health class and state rules affect pricing; a licensed specialist underwrites the real offer.",
        adaptiveOverlayTitle: "Life insurance illustrations",
        adaptiveOverlaySubtitle:
          "Compare 10-year term, 20-year level term, and longer protection sketches.",
        adaptiveFooterNote: "Insurance · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details to connect with a licensed specialist.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(503) 555-0167",
          company: "Acme Corp",
          zipCode: "97205",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Short bridge",
            title: "10-year level term",
            iconClass: "fa-shield-heart",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "FACE", value: "$500k" }, { label: "EST. PREM", value: "$42/mo" }],
            features: [
              "Income bridge during a loan payoff window",
              "Convertibility to discuss",
              "Exam may be required",
              "Subject to underwriting",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Family",
            title: "20-year level term",
            iconClass: "fa-shield-heart",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "FACE", value: "$1M" }, { label: "EST. PREM", value: "$78/mo" }],
            features: [
              "Common horizon for young families",
              "Fixed premium during term",
              "Rider options with agent",
              "Beneficiary review",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "Longer",
            title: "30-year level term",
            iconClass: "fa-shield-heart",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "FACE", value: "$750k" }, { label: "EST. PREM", value: "$115/mo" }],
            features: [
              "Longer mortgage alignment story",
              "Higher total premium vs shorter term",
              "Permanent options separate conversation",
              "Final rates via underwriting",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
      bundleHomeAuto: {
        name: "Bundle home & auto",
        heroAssets: {
          warmHero:
            "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          coldHero:
            "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=1600&q=80",
          insight1:
            "https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=900&q=80",
          insight2:
            "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=900&q=80",
          insight3:
            "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=900&q=80",
        },
        vanillaHeroTitle: "Protection for what drives you and what you call home.",
        vanillaHeroSubtext:
          "Bundle auto and home, review life coverage, and add umbrella liability with licensed specialists.",
        userIntentString: "I need to bundle my home and auto insurance.",
        agentChatMessage: ADAPTIVE_GENERIC_AGENT_GREETING,
        chatWidgetTitle: "Penny (${brandName} AI Agent)",
        agentAdaptiveResponse:
          "If you are bundling policies, here are three package tiers to compare—final pricing and discounts come from a licensed agent.",
        adaptiveOverlayTitle: "Bundle and coverage options",
        adaptiveOverlaySubtitle:
          "Compare Essential, Enhanced, and Premier home-and-auto bundle tiers with a licensed specialist.",
        adaptiveFooterNote: "Insurance · Demo experience",
        landingPageTitle: "Secure your details",
        landingPageSubtitle: "Confirm your details to connect with a licensed specialist.",
        mockProfile: {
          firstName: "Rachel",
          lastName: "Morris",
          email: "rachel.morris@example.com",
          phone: "(503) 555-0167",
          company: "Acme Corp",
          zipCode: "97205",
        },
        cards: [
          {
            recommended: false,
            smallTag: "Core Coverage",
            title: "Essential Bundle",
            iconClass: "fa-shield",
            iconBgClass: "bg-slate-100",
            iconColorClass: "text-slate-600",
            metrics: [{ label: "SAVINGS", value: "10%" }, { label: "DEDUCTIBLE", value: "Split" }],
            features: [
              "State minimum auto limits",
              "Standard dwelling protection",
              "Digital claims tracking",
              "Affordable monthly premiums",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: true,
            badgeText: "Best Match",
            smallTag: "Recommended",
            title: "Enhanced Protection Bundle",
            iconClass: "fa-shield-halved",
            iconBgClass: "bg-sky-50",
            metrics: [{ label: "SAVINGS", value: "15%" }, { label: "DEDUCTIBLE", value: "Single" }],
            features: [
              "Single deductible for shared events",
              "Replacement cost plus for home",
              "Accident forgiveness",
              "24/7 roadside assistance",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
          {
            recommended: false,
            smallTag: "High Limit",
            title: "Premier Shield Bundle",
            iconClass: "fa-umbrella",
            iconBgClass: "bg-emerald-50",
            iconColorClass: "text-emerald-600",
            metrics: [{ label: "SAVINGS", value: "18%" }, { label: "UMBRELLA", value: "Included" }],
            features: [
              "Maximum liability limits",
              "$1M Personal Umbrella included",
              "Valuable items rider",
              "Priority concierge claims support",
            ],
            bundleText: "",
            ctaLabel: "Learn more",
          },
        ],
      },
    },
    warmInsights: [
      {
        image:
          "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Home",
        title: "Review replacement cost as values change",
        body: "Construction and material costs move over time; an annual policy check helps limits keep pace so a claim does not fall short of rebuild reality.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Auto",
        title: "Liability limits that match how you drive and what you own",
        body: "Higher limits can matter after a serious accident—especially if you commute often, carry passengers, or have growing assets to protect.",
      },
      {
        image:
          "https://images.unsplash.com/photo-1449965408861-eb3a11764c7d?auto=format&fit=crop&w=900&q=80",
        eyebrow: "Protection",
        title: "When an umbrella policy is worth a conversation",
        body: "An umbrella can add an extra layer above auto and home liability—useful if you host often, own rental property, or serve on a board.",
      },
    ],
  },
};

const CUMULUS_ASSET_LIBRARY = {
  retailBanking: {
    coldHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231650/Couple_Budgeting_aozhqd.webp",
    warmHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201534/Hero_-_Woman_with_Credit_Card_nwnxhd.jpg",
    insight1:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
    insight2:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201481/Student-Credit-Card_a8038n.jpg",
    insight3:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
  },
  commercialBanking: {
    coldHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201669/S-Corp-Payroll-586_vmwlfq.jpg",
    warmHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp",
    insight1:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233491/economic-trends-as-interest-rates-move-2x-jpg_cmufdc.webp",
    insight2:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232863/Screenshot_2026-03-22_at_9.27.23_PM_bzbibz.png",
    insight3:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232863/Screenshot_2026-03-22_at_9.27.23_PM_bzbibz.png",
  },
  wealthManagement: {
    coldHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232720/RGB-JPG-GS_VM_Photo_WS_NYC_00276_bviiz1.avif",
    warmHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231728/Rollover_IRAs_qmvvmo.webp",
    insight1:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201708/ways-to-maximize-your-retirement-life-1_okcwtq.jpg",
    insight2:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201707/Sixty-and-Me_How-to-Live-in-Luxury-in-Retirement_-No-Matter-Your-Budget_xcg3ws.jpg",
    insight3:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
  },
  assetManagement: {
    coldHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201514/Hero_-_Business_Meeting_junktj.png",
    warmHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232679/GS_VM_Photo_SH_NYC3_11375_RGB_uuyclk.webp",
    insight1:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233012/image.20220301_ewuyt6.jpg",
    insight2:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233219/asset-management-2x-jpg_hmxhkr.webp",
    insight3:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233150/professional-investment-advisory-intro-2x-jpg_uflsrq.jpg",
  },
  insurance: {
    coldHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201645/Gemini_Generated_Image_3kok5s3kok5s3kok_kyl5ne.png",
    warmHero:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
    insight1:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201646/Gemini_Generated_Image_o412gao412gao412_p0e0to.png",
    insight2:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233587/business-auto-insurance-intro-2x-jpg_myb7kd.jpg",
    insight3:
      "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774202333/auto-insurance-insurance-options_wtctvt.png",
  },
};

const ADAPTIVE_MATRIX_OVERRIDES = {
  "retailBanking": {
    "useCases": {
      "studentLoanRefi": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479781/Loans_How_to_refinance_your_student_loans_in_5_steps_fosnuh.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479140/GettyImages-2194268868_Feature-Single-R_zmffb8.webp"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Market insights and resources.",
          "cards": [
            {
              "eyebrow": "Treasury",
              "title": "Travel Rewards for Every Journey",
              "body": "Turn your daily expenses into your next dream getaway with premium travel cards."
            },
            {
              "eyebrow": "Planning",
              "title": "Planning for a Lasting Legacy",
              "body": "It is never too early to start planning for wealth preservation and family security."
            },
            {
              "eyebrow": "Auto",
              "title": "Your First Major Purchase",
              "body": "Lock in a competitive rate and search with confidence for your next vehicle."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Education",
              "title": "Student Loan Refinance Calculator",
              "body": "Model your new monthly payments and see exactly how much you can save over time."
            },
            {
              "eyebrow": "Lending",
              "title": "Starting Your Small Business",
              "body": "Explore SBA loan options and resources designed for young entrepreneurs looking to scale."
            },
            {
              "eyebrow": "Education",
              "title": "Path to Financial Independence",
              "body": "Practical advice for managing debt while building a professional foundation after graduation."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Fast Payoff",
            "title": "5-Year Fixed",
            "badgeText": "",
            "metrics": [
              {
                "label": "APR",
                "value": "4.99%"
              },
              {
                "label": "TERM",
                "value": "60 Mo"
              }
            ],
            "features": [
              "Lowest interest rate available",
              "Get out of debt faster",
              "Fixed predictable payments",
              "0.25% AutoPay discount"
            ]
          },
          {
            "smallTag": "Best Match",
            "title": "10-Year Fixed",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "APR",
                "value": "5.50%"
              },
              {
                "label": "TERM",
                "value": "120 Mo"
              }
            ],
            "features": [
              "Balanced monthly payments",
              "Standard repayment timeline",
              "Consolidate federal and private",
              "No origination fees"
            ]
          },
          {
            "smallTag": "Flexible",
            "title": "7-Year Variable",
            "badgeText": "",
            "metrics": [
              {
                "label": "EST. APR",
                "value": "4.75%"
              },
              {
                "label": "CAP",
                "value": "8.95%"
              }
            ],
            "features": [
              "Lower starting interest rate",
              "Rate capped for your protection",
              "Ideal if paying off aggressively",
              "Release co-signer after 24 months"
            ]
          }
        ]
      },
      "autoLoan": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201481/Student-Credit-Card_a8038n.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479242/1a-blogposts-When-Refinancing-an-Auto-Loan-Makes-Sense_yc7s9g.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774202333/auto-insurance-insurance-options_wtctvt.png",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479720/quarters-stacked-on-a-table-and-a-jar-with-a-growing-sprout_dgntpn.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Market insights and resources.",
          "cards": [
            {
              "eyebrow": "Education",
              "title": "Student Credit Cards for Beginners",
              "body": "Building credit early helps you qualify for better rates on future loans and major purchases."
            },
            {
              "eyebrow": "Travel",
              "title": "Maximize Your Travel Rewards",
              "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder."
            },
            {
              "eyebrow": "Planning",
              "title": "Planning for Retirement Early",
              "body": "Starting retirement savings in your 20s and 30s gives compound interest decades to work in your favor."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Auto",
              "title": "Auto Loan Refinancing Benefits",
              "body": "Lower your monthly payment or shorten your loan term by refinancing when rates drop or your credit improves."
            },
            {
              "eyebrow": "Insurance",
              "title": "Auto Insurance Essentials",
              "body": "Comprehensive and collision coverage protect your investment—shop rates annually to ensure competitive pricing."
            },
            {
              "eyebrow": "Savings",
              "title": "Building an Emergency Fund",
              "body": "Three to six months of expenses in savings protects you from unexpected repairs and financial setbacks."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Fast Payoff",
            "title": "36-Month Auto Loan",
            "badgeText": "",
            "metrics": [
              {
                "label": "APR",
                "value": "5.49%"
              },
              {
                "label": "TERM",
                "value": "36 mo"
              }
            ],
            "features": [
              "Lowest interest rate",
              "Pay off your vehicle faster",
              "No prepayment penalties",
              "Same-day funding"
            ]
          },
          {
            "smallTag": "Balanced",
            "title": "60-Month Auto Loan",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "APR",
                "value": "6.25%"
              },
              {
                "label": "TERM",
                "value": "60 mo"
              }
            ],
            "features": [
              "Balanced monthly payments",
              "Competitive interest rate",
              "Rate lock for 30 days",
              "Automatic payment discount"
            ]
          },
          {
            "smallTag": "Low Payment",
            "title": "72-Month Auto Loan",
            "badgeText": "",
            "metrics": [
              {
                "label": "APR",
                "value": "6.99%"
              },
              {
                "label": "TERM",
                "value": "72 mo"
              }
            ],
            "features": [
              "Lowest monthly payment",
              "Maximum vehicle purchasing power",
              "100% digital application",
              "Skip a payment program"
            ]
          }
        ]
      },
      "creditCard": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479242/1a-blogposts-When-Refinancing-an-Auto-Loan-Makes-Sense_yc7s9g.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472577/young-woman-laptop-home_padiak.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201707/Sixty-and-Me_How-to-Live-in-Luxury-in-Retirement_-No-Matter-Your-Budget_xcg3ws.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Market insights and resources.",
          "cards": [
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            },
            {
              "eyebrow": "Planning", "title": "Financial Planning Strategies", "body": "Goal-based planning, regular reviews, and flexible strategies help you adapt to life changes and market conditions."
            },
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Best Match",
            "title": "Premium Travel Rewards",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "ANNUAL FEE",
                "value": "$95"
              },
              {
                "label": "SIGN-UP BONUS",
                "value": "50k Miles"
              }
            ],
            "features": [
              "3x miles on flights and hotels",
              "Complimentary lounge access",
              "No foreign transaction fees",
              "TSA PreCheck statement credit"
            ]
          },
          {
            "smallTag": "No Fee",
            "title": "Cash Back Plus",
            "badgeText": "",
            "metrics": [
              {
                "label": "ANNUAL FEE",
                "value": "$0"
              },
              {
                "label": "CASH BACK",
                "value": "2% Flat"
              }
            ],
            "features": [
              "2% cash back on all purchases",
              "0% Intro APR for 15 months",
              "No category tracking required",
              "Zero fraud liability"
            ]
          },
          {
            "smallTag": "Luxury",
            "title": "Platinum Reserve",
            "badgeText": "",
            "metrics": [
              {
                "label": "ANNUAL FEE",
                "value": "$450"
              },
              {
                "label": "SIGN-UP BONUS",
                "value": "100k Miles"
              }
            ],
            "features": [
              "5x miles on flights and dining",
              "$300 annual travel credit",
              "Global Entry fee credit",
              "24/7 Premium Concierge"
            ]
          }
        ]
      },
      "homeEquity": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472577/young-woman-laptop-home_padiak.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479072/young-couple-renovating-home-and-dancing-in-living-room-EIF03304_wzfeup.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478992/AdobeStock_300463851-scaled_v86hcy.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Market insights and resources.",
          "cards": [
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            },
            {
              "eyebrow": "Planning", "title": "Financial Planning Strategies", "body": "Goal-based planning, regular reviews, and flexible strategies help you adapt to life changes and market conditions."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Flexible",
            "title": "Home Equity Line of Credit",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "RATE",
                "value": "7.25%"
              },
              {
                "label": "LINE",
                "value": "Up to $100k"
              }
            ],
            "features": [
              "Draw funds only as you need them",
              "Pay interest only on what you use",
              "Reusable credit line",
              "Variable interest rate"
            ]
          },
          {
            "smallTag": "Predictable",
            "title": "Fixed Home Equity Loan",
            "badgeText": "",
            "metrics": [
              {
                "label": "RATE",
                "value": "6.99%"
              },
              {
                "label": "TERM",
                "value": "15 Years"
              }
            ],
            "features": [
              "Receive a lump sum upfront",
              "Fixed monthly payments",
              "Ideal for one-time large projects",
              "Fixed interest rate"
            ]
          },
          {
            "smallTag": "Consolidated",
            "title": "Cash-Out Refinance",
            "badgeText": "",
            "metrics": [
              {
                "label": "RATE",
                "value": "5.85%"
              },
              {
                "label": "CASH OUT",
                "value": "Up to $75k"
              }
            ],
            "features": [
              "Replace your existing mortgage",
              "Potentially lower your primary rate",
              "One single monthly payment",
              "Maximize your borrowing power"
            ]
          }
        ]
      },
      "mortgageRefi": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479639/exterior-cape-cod-house-mem-interiors-pc-r-brad-knipstein_d4kp5r.webp",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472577/young-woman-laptop-home_padiak.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201707/Sixty-and-Me_How-to-Live-in-Luxury-in-Retirement_-No-Matter-Your-Budget_xcg3ws.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479544/1-JacobWackerhausen-417d5105246c4947bc3cad2a961af80a_j8cfgh.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Market insights and resources.",
          "cards": [
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            },
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            },
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Lowest Payment",
            "title": "30-Year Fixed Refi",
            "badgeText": "",
            "metrics": [
              {
                "label": "RATE",
                "value": "5.50%"
              },
              {
                "label": "APR",
                "value": "5.65%"
              }
            ],
            "features": [
              "Drop your monthly payment",
              "Improve monthly cash flow",
              "No prepayment penalty",
              "Escrow management included"
            ]
          },
          {
            "smallTag": "Best Value",
            "title": "15-Year Fixed Refi",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "RATE",
                "value": "4.99%"
              },
              {
                "label": "APR",
                "value": "5.15%"
              }
            ],
            "features": [
              "Pay off your home faster",
              "Save thousands in total interest",
              "Build equity rapidly",
              "Dedicated closing team"
            ]
          },
          {
            "smallTag": "Liquidity",
            "title": "Cash-Out Refinance",
            "badgeText": "",
            "metrics": [
              {
                "label": "RATE",
                "value": "5.85%"
              },
              {
                "label": "CASH OUT",
                "value": "Up to $50k"
              }
            ],
            "features": [
              "Fund home improvements",
              "Consolidate high-interest debt",
              "Leverage existing home equity",
              "Potential tax deductions"
            ]
          }
        ]
      },
      "depositCapture": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479329/shutterstock_1107968786_vagxeh.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479072/young-couple-renovating-home-and-dancing-in-living-room-EIF03304_wzfeup.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479720/quarters-stacked-on-a-table-and-a-jar-with-a-growing-sprout_dgntpn.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472577/young-woman-laptop-home_padiak.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Market insights and resources.",
          "cards": [
            {
              "eyebrow": "Travel", "title": "Maximize Your Travel Rewards", "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder."
            },
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Savings", "title": "High-Yield Savings Strategies", "body": "Automatic transfers and competitive APYs help you build emergency funds and reach short-term goals faster."
            },
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Planning", "title": "Financial Planning Strategies", "body": "Goal-based planning, regular reviews, and flexible strategies help you adapt to life changes and market conditions."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Liquid",
            "title": "High-Yield Savings",
            "badgeText": "",
            "metrics": [
              {
                "label": "APY",
                "value": "4.35%"
              },
              {
                "label": "MINIMUM",
                "value": "$0"
              }
            ],
            "features": [
              "Total liquidity and easy transfers",
              "No monthly maintenance fees",
              "FDIC insured up to $250k",
              "Interest compounded daily"
            ]
          },
          {
            "smallTag": "Highest Rate",
            "title": "6-Month CD",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "APY",
                "value": "5.10%"
              },
              {
                "label": "TERM",
                "value": "6 Months"
              }
            ],
            "features": [
              "Lock in our highest guaranteed rate",
              "Short-term commitment",
              "No market risk",
              "Automatic renewal options"
            ]
          },
          {
            "smallTag": "Balanced",
            "title": "Premium Money Market",
            "badgeText": "",
            "metrics": [
              {
                "label": "APY",
                "value": "4.50%"
              },
              {
                "label": "MINIMUM",
                "value": "$25k"
              }
            ],
            "features": [
              "Check-writing privileges",
              "Debit card access",
              "Tiered interest rates",
              "Perfect for emergency funds"
            ]
          }
        ]
      },
      "mortgage": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479639/exterior-cape-cod-house-mem-interiors-pc-r-brad-knipstein_d4kp5r.webp",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472484/confident-student-in-shared-space-with-laptop_collagestyle_zeay8z.avif",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479720/quarters-stacked-on-a-table-and-a-jar-with-a-growing-sprout_dgntpn.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479544/1-JacobWackerhausen-417d5105246c4947bc3cad2a961af80a_j8cfgh.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774480084/milan2099-61cf06cdda72490bb75bb448fd03aaae_r62pz0.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479444/Livery-Insurance-Close-up-Portrait-of-a-Woman-Driver-of-a-Car-Service-Smiling-at-the-Camera_vynex8.webp"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Market insights and resources.",
          "cards": [
            {
              "eyebrow": "Education", "title": "Student Loan Management", "body": "Understanding repayment options helps you manage debt while building your career and financial foundation."
            },
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            },
            {
              "eyebrow": "Savings", "title": "High-Yield Savings Strategies", "body": "Automatic transfers and competitive APYs help you build emergency funds and reach short-term goals faster."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            },
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Predictable",
            "title": "30-Year Fixed Mortgage",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "RATE",
                "value": "6.50%"
              },
              {
                "label": "APR",
                "value": "6.65%"
              }
            ],
            "features": [
              "Predictable monthly payments",
              "First-time buyer grants available",
              "Lock your rate for 60 days",
              "Dedicated loan officer"
            ]
          },
          {
            "smallTag": "Fast Equity",
            "title": "15-Year Fixed Mortgage",
            "badgeText": "",
            "metrics": [
              {
                "label": "RATE",
                "value": "5.99%"
              },
              {
                "label": "APR",
                "value": "6.15%"
              }
            ],
            "features": [
              "Build equity twice as fast",
              "Lower interest rate",
              "Save thousands in total interest",
              "Fast-track closing"
            ]
          },
          {
            "smallTag": "Flexible",
            "title": "5/1 ARM",
            "badgeText": "",
            "metrics": [
              {
                "label": "INITIAL RATE",
                "value": "5.75%"
              },
              {
                "label": "APR",
                "value": "6.85%"
              }
            ],
            "features": [
              "Lowest initial payment",
              "Fixed for the first 5 years",
              "Ideal if you plan to move soon",
              "No prepayment penalties"
            ]
          }
        ]
      }
    }
  },
  "commercialBanking": {
    "useCases": {
      "treasuryServices": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481597/20190731_WeWork_SonyCenter_Berlin_008_v1_gbyy1w.webp",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482481/What-is-Treasury-Management_ygnigo.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201708/ways-to-maximize-your-retirement-life-1_okcwtq.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479639/exterior-cape-cod-house-mem-interiors-pc-r-brad-knipstein_d4kp5r.webp",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482724/calculator-1516869_1920_ipeyrd.webp",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Business banking insights.",
          "cards": [
            {
              "eyebrow": "Travel",
              "title": "Maximize Your Travel Rewards",
              "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder for you."
            },
            {
              "eyebrow": "Retirement",
              "title": "Planning for Your Golden Years",
              "body": "Retirement planning starts with understanding your timeline, risk tolerance, and income needs for the future."
            },
            {
              "eyebrow": "Real Estate",
              "title": "First-Time Homebuyer Essentials",
              "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Treasury",
              "title": "Optimize Your Cash Position",
              "body": "Real-time visibility into receivables and payables helps finance teams forecast accurately and fund operations without emergency draws."
            },
            {
              "eyebrow": "Treasury",
              "title": "Automate Reconciliation Workflows",
              "body": "Automated matching and reporting reduce manual errors and free up your team to focus on strategic priorities."
            },
            {
              "eyebrow": "Risk",
              "title": "Protect Your Business Assets",
              "body": "Property and liability coverage protects earnings as your operations scale—worth revisiting as revenue mix changes."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Payables",
            "title": "Business Payables Hub",
            "badgeText": "",
            "metrics": [
              {
                "label": "CHANNELS",
                "value": "ACH + wire"
              },
              {
                "label": "CONTROLS",
                "value": "Dual approval"
              }
            ],
            "features": [
              "Centralize vendor payments",
              "Positive pay for checks",
              "Scheduled releases",
              "Audit-friendly reporting"
            ]
          },
          {
            "smallTag": "Receivables",
            "title": "Receivables Acceleration",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "DEPOSITS",
                "value": "Same day"
              },
              {
                "label": "MATCHING",
                "value": "Auto"
              }
            ],
            "features": [
              "Faster deposit posting",
              "Remittance detail capture",
              "Receivables reporting",
              "Works with common accounting tools"
            ]
          },
          {
            "smallTag": "Liquidity",
            "title": "Liquidity & reporting snapshot",
            "badgeText": "",
            "metrics": [
              {
                "label": "VIEW",
                "value": "Multi-acct"
              },
              {
                "label": "ALERTS",
                "value": "Configurable"
              }
            ],
            "features": [
              "Cash position visibility",
              "Forecast-friendly exports",
              "Fraud monitoring hooks",
              "Scales as accounts grow"
            ]
          }
        ]
      },
      "smallBusinessTermLoan": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481597/20190731_WeWork_SonyCenter_Berlin_008_v1_gbyy1w.webp",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479720/quarters-stacked-on-a-table-and-a-jar-with-a-growing-sprout_dgntpn.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201481/Student-Credit-Card_a8038n.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479242/1a-blogposts-When-Refinancing-an-Auto-Loan-Makes-Sense_yc7s9g.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774483106/what-is-a-small-business-loan-sba-7a-504-live-oak-bank-blog_eodueq.webp",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482724/calculator-1516869_1920_ipeyrd.webp"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Business banking insights.",
          "cards": [
            {
              "eyebrow": "Savings",
              "title": "High-Yield Savings Strategies",
              "body": "Automatic transfers and competitive APYs help you build emergency funds and reach short-term goals faster."
            },
            {
              "eyebrow": "Education",
              "title": "Student Loan Repayment Options",
              "body": "Understanding federal vs. private loans helps you choose the right repayment strategy for your financial goals."
            },
            {
              "eyebrow": "Auto",
              "title": "Financing Your Next Vehicle",
              "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Lending",
              "title": "Small Business Term Loans Explained",
              "body": "Fixed-rate term loans provide predictable payments for equipment purchases, renovations, or working capital needs."
            },
            {
              "eyebrow": "Lending",
              "title": "Growing Your Business with Financing",
              "body": "Strategic use of debt can accelerate growth while preserving cash reserves for operations and unexpected needs."
            },
            {
              "eyebrow": "Planning",
              "title": "Understanding Business Loan Terms",
              "body": "Match your loan duration to asset life—shorter terms mean less interest, longer terms preserve monthly cash flow."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Faster payoff",
            "title": "36-Month Term Loan",
            "badgeText": "",
            "metrics": [
              {
                "label": "PAYMENT",
                "value": "Higher"
              },
              {
                "label": "INTEREST",
                "value": "Lower total"
              }
            ],
            "features": [
              "Retire debt sooner",
              "Less total interest vs longer terms",
              "Good for near-term projects",
              "Fixed payment schedule"
            ]
          },
          {
            "smallTag": "Balanced",
            "title": "60-Month Term Loan",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "PAYMENT",
                "value": "Moderate"
              },
              {
                "label": "STRUCTURE",
                "value": "Fixed"
              }
            ],
            "features": [
              "Balanced monthly cash flow",
              "Suited to expansion or refinance",
              "Dedicated closing support",
              "Covenant discussion with your team"
            ]
          },
          {
            "smallTag": "Lower payment",
            "title": "84-Month Term Loan",
            "badgeText": "",
            "metrics": [
              {
                "label": "PAYMENT",
                "value": "Lower"
              },
              {
                "label": "USE CASE",
                "value": "Capex"
              }
            ],
            "features": [
              "Smaller monthly obligation",
              "Pairs with longer-lived assets",
              "Preserves near-term liquidity",
              "Subject to credit approval"
            ]
          }
        ]
      },
      "businessLineOfCredit": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481597/20190731_WeWork_SonyCenter_Berlin_008_v1_gbyy1w.webp",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482364/istockphoto-1304746031-612x612_ccrxbd.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233012/image.20220301_ewuyt6.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774741705/life-insurance_cets0p.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774483106/what-is-a-small-business-loan-sba-7a-504-live-oak-bank-blog_eodueq.webp",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231650/Couple_Budgeting_aozhqd.webp",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Business banking insights.",
          "cards": [
            {
              "eyebrow": "Investing",
              "title": "Building a Diversified Portfolio",
              "body": "Asset allocation across stocks, bonds, and alternatives helps balance growth potential with downside protection."
            },
            {
              "eyebrow": "Insurance",
              "title": "Life Insurance for Family Protection",
              "body": "Term and permanent life insurance options provide financial security for your loved ones."
            },
            {
              "eyebrow": "Credit",
              "title": "Travel Rewards That Work for You",
              "body": "Premium credit cards offer points, cashback, and travel perks that align with your spending habits."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Lending",
              "title": "Business Lines of Credit Explained",
              "body": "Revolving credit provides flexible access to working capital when you need it most—pay interest only on what you use."
            },
            {
              "eyebrow": "Treasury",
              "title": "Managing Seasonal Cash Flow",
              "body": "A revolving line smooths out receivables timing and covers payroll during seasonal revenue gaps."
            },
            {
              "eyebrow": "Lending",
              "title": "Growing with Working Capital",
              "body": "Flexible financing helps businesses scale operations, manage inventory, and seize opportunities without depleting reserves."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Starter",
            "title": "Secured Business Line",
            "badgeText": "",
            "metrics": [
              {
                "label": "CAPACITY",
                "value": "Up to $250k"
              },
              {
                "label": "ACCESS",
                "value": "Online"
              }
            ],
            "features": [
              "Collateral-backed capacity",
              "Lower pricing vs unsecured",
              "Renewal subject to review",
              "Good for predictable draws"
            ]
          },
          {
            "smallTag": "Growth",
            "title": "Revolving Operating Line",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "CAPACITY",
                "value": "Up to $750k"
              },
              {
                "label": "ACCESS",
                "value": "Same-day"
              }
            ],
            "features": [
              "Revolving capacity for payroll",
              "Cash sweep integration",
              "Interest on outstanding balance only",
              "Covenant package tailored in underwriting"
            ]
          },
          {
            "smallTag": "Scale",
            "title": "Asset-Based Line",
            "badgeText": "",
            "metrics": [
              {
                "label": "CAPACITY",
                "value": "Formula"
              },
              {
                "label": "COLLATERAL",
                "value": "A/R"
              }
            ],
            "features": [
              "Borrowing base tied to receivables",
              "Supports faster growth cycles",
              "Monitoring and reporting cadence",
              "Specialist onboarding"
            ]
          }
        ]
      },
      "equipmentFinance": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481597/20190731_WeWork_SonyCenter_Berlin_008_v1_gbyy1w.webp",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482562/HanmiBank-Equipment-Leasing_pgktwd.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479639/exterior-cape-cod-house-mem-interiors-pc-r-brad-knipstein_d4kp5r.webp",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479720/quarters-stacked-on-a-table-and-a-jar-with-a-growing-sprout_dgntpn.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678306/what-makes-a-contract-not-enforceable-scaled_1_eeu6xh.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774483177/what-is-equipment-leasing_j6b3db.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482724/calculator-1516869_1920_ipeyrd.webp",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Business banking insights.",
          "cards": [
            {
              "eyebrow": "Home",
              "title": "Refinancing Your Mortgage",
              "body": "Lower rates or cash-out refinancing can reduce monthly payments or fund home improvements."
            },
            {
              "eyebrow": "Savings",
              "title": "High-Yield Savings Strategies",
              "body": "Automatic transfers and competitive APYs help you build emergency funds and reach short-term goals faster."
            },
            {
              "eyebrow": "Planning",
              "title": "Estate Planning Essentials",
              "body": "Wills, trusts, and beneficiary designations ensure your assets transfer according to your wishes."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Equipment",
              "title": "Equipment Leasing Explained",
              "body": "Leases preserve capital and offer flexibility for technology and machinery that refreshes frequently."
            },
            {
              "eyebrow": "Planning",
              "title": "Tax Benefits of Equipment Financing",
              "body": "Section 179 deductions and bonus depreciation can significantly reduce taxable income on qualifying asset purchases."
            },
            {
              "eyebrow": "Lending",
              "title": "Financing Business Growth",
              "body": "Strategic equipment financing helps businesses scale operations without depleting cash reserves needed for daily operations."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Capex",
            "title": "Equipment term financing",
            "badgeText": "",
            "metrics": [
              {
                "label": "FINANCING",
                "value": "Up to 100%"
              },
              {
                "label": "TERMS",
                "value": "Flexible"
              }
            ],
            "features": [
              "Preserve working capital",
              "Bundle equipment and soft costs",
              "Scheduled draws",
              "Amortization aligned to asset life"
            ]
          },
          {
            "smallTag": "Vehicles",
            "title": "Fleet & vehicle program",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "STRUCTURE",
                "value": "Fixed"
              },
              {
                "label": "TITLE",
                "value": "Lien"
              }
            ],
            "features": [
              "Multiple unit scheduling",
              "End-of-term options to discuss",
              "Insurance requirements apply",
              "Relationship manager coordination"
            ]
          },
          {
            "smallTag": "Tech",
            "title": "Technology & machinery lease-style",
            "badgeText": "",
            "metrics": [
              {
                "label": "UPGRADE",
                "value": "Optional"
              },
              {
                "label": "TERM",
                "value": "36–60 mo"
              }
            ],
            "features": [
              "Technology refresh flexibility",
              "Predictable payments",
              "End-of-term choices",
              "Rates subject to approval"
            ]
          }
        ]
      }
    }
  },
  "wealthManagement": {
    "useCases": {
      "retirementPlanning": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774676522/smiling-middle-aged-couple-with-laptop-studying-documents-while-working-couch-home_650366-839_ay2t1b.avif",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482228/SOSB0324009_1560x880_desktop_vpn0nd.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678306/what-makes-a-contract-not-enforceable-scaled_1_eeu6xh.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774677512/shutterstock_1414416203-600x400_sdr4my.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482724/calculator-1516869_1920_ipeyrd.webp",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774676522/smiling-middle-aged-couple-with-laptop-studying-documents-while-working-couch-home_650366-839_ay2t1b.avif"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Planning and wealth insights.",
          "cards": [
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            },
            {
              "eyebrow": "Planning", "title": "Financial Planning Strategies", "body": "Goal-based planning, regular reviews, and flexible strategies help you adapt to life changes and market conditions."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Growth",
            "title": "Growth-oriented glide path",
            "badgeText": "",
            "metrics": [
              {
                "label": "HORIZON",
                "value": "15+ yr"
              },
              {
                "label": "RISK",
                "value": "Higher"
              }
            ],
            "features": [
              "Emphasis on long-term compounding",
              "Periodic rebalancing discussion",
              "Tax location awareness",
              "Rates subject to approval"
            ]
          },
          {
            "smallTag": "Balanced",
            "title": "Balanced retirement portfolio",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "MIX",
                "value": "60/40"
              },
              {
                "label": "REVIEW",
                "value": "Annual"
              }
            ],
            "features": [
              "Growth with volatility moderation",
              "Cash-flow planning checkpoints",
              "Employer plan coordination",
              "Advisor-led adjustments"
            ]
          },
          {
            "smallTag": "Income",
            "title": "Income-first approach",
            "badgeText": "",
            "metrics": [
              {
                "label": "FOCUS",
                "value": "Cash flow"
              },
              {
                "label": "DRAWDOWN",
                "value": "Planned"
              }
            ],
            "features": [
              "Steadier distribution planning",
              "Longevity and healthcare considerations",
              "Tax-aware withdrawal order",
              "Not a product recommendation"
            ]
          }
        ]
      },
      "educationSavings529": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774676522/smiling-middle-aged-couple-with-laptop-studying-documents-while-working-couch-home_650366-839_ay2t1b.avif",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201707/Sixty-and-Me_How-to-Live-in-Luxury-in-Retirement_-No-Matter-Your-Budget_xcg3ws.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479720/quarters-stacked-on-a-table-and-a-jar-with-a-growing-sprout_dgntpn.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479639/exterior-cape-cod-house-mem-interiors-pc-r-brad-knipstein_d4kp5r.webp",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479781/Loans_How_to_refinance_your_student_loans_in_5_steps_fosnuh.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774478809/GettyImages-1397579313_Feature-Single-R_fyxtza.webp",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774677689/Newborn-Care-Class-3_kymwyr.webp"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Planning and wealth insights.",
          "cards": [
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Savings", "title": "High-Yield Savings Strategies", "body": "Automatic transfers and competitive APYs help you build emergency funds and reach short-term goals faster."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Education", "title": "Student Loan Management", "body": "Understanding repayment options helps you manage debt while building your career and financial foundation."
            },
            {
              "eyebrow": "Planning", "title": "Financial Planning Strategies", "body": "Goal-based planning, regular reviews, and flexible strategies help you adapt to life changes and market conditions."
            },
            {
              "eyebrow": "Education", "title": "Student Loan Management", "body": "Understanding repayment options helps you manage debt while building your career and financial foundation."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Long horizon",
            "title": "Age-based glide path",
            "badgeText": "",
            "metrics": [
              {
                "label": "STYLE",
                "value": "Auto shift"
              },
              {
                "label": "HORIZON",
                "value": "10+ yr"
              }
            ],
            "features": [
              "Equity tilt when young",
              "Gradual risk reduction",
              "Good for “set and review” savers",
              "Plan features vary—ask your advisor"
            ]
          },
          {
            "smallTag": "Balanced",
            "title": "Balanced education portfolio",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "MIX",
                "value": "Moderate"
              },
              {
                "label": "REVIEW",
                "value": "Yearly"
              }
            ],
            "features": [
              "Stocks and bonds blend",
              "Flexible for K–12 or college goals",
              "Contribution planning conversation",
              "Rates vary by property"
            ]
          },
          {
            "smallTag": "Near term",
            "title": "Capital preservation tilt",
            "badgeText": "",
            "metrics": [
              {
                "label": "VOLATILITY",
                "value": "Lower"
              },
              {
                "label": "USE",
                "value": "Soon"
              }
            ],
            "features": [
              "Emphasis on stability near enrollment",
              "Spending flexibility discussion",
              "Gift and tax topics with counsel",
              "Not tax or legal advice"
            ]
          }
        ]
      },
      "iraInvesting": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774676522/smiling-middle-aged-couple-with-laptop-studying-documents-while-working-couch-home_650366-839_ay2t1b.avif",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678050/What-Do-Clients-Want-from-Their-Financial-Advisor_zj97bu.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201707/Sixty-and-Me_How-to-Live-in-Luxury-in-Retirement_-No-Matter-Your-Budget_xcg3ws.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678008/633408_RET-107794_financial-tips-multiGeneration_vpHero_1200x628_i23bsh.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774677784/bigstock-Roth-Ira-Vs-Traditional-Ira-Wr-277133656-1024x683.jpg_hkws9f.webp",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774677938/BBVA-acciones-como-funcionan-salud-financiera_elzzqe.avif",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774677862/gettyimages-1319571139_hero_dfbiqz.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Planning and wealth insights.",
          "cards": [
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Planning", "title": "Financial Planning Strategies", "body": "Goal-based planning, regular reviews, and flexible strategies help you adapt to life changes and market conditions."
            },
            {
              "eyebrow": "Planning", "title": "Financial Planning Strategies", "body": "Goal-based planning, regular reviews, and flexible strategies help you adapt to life changes and market conditions."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Simple",
            "title": "Core index allocation",
            "badgeText": "",
            "metrics": [
              {
                "label": "STYLE",
                "value": "Broad market"
              },
              {
                "label": "FEES",
                "value": "0.45%"
              }
            ],
            "features": [
              "US and international sleeves",
              "Rebalancing discipline",
              "Straightforward reporting",
              "Not a recommendation"
            ]
          },
          {
            "smallTag": "Advisory",
            "title": "Advisory mutual fund lineup",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "SUPPORT",
                "value": "Ongoing"
              },
              {
                "label": "MIX",
                "value": "Diversified"
              }
            ],
            "features": [
              "Fund selection support",
              "Risk and goal check-ins",
              "Tax-aware placement where appropriate",
              "Demo experience"
            ]
          },
          {
            "smallTag": "Stability",
            "title": "Conservative balanced IRA",
            "badgeText": "",
            "metrics": [
              {
                "label": "BONDS",
                "value": "Higher %"
              },
              {
                "label": "VOL",
                "value": "Lower"
              }
            ],
            "features": [
              "Emphasis on downside moderation",
              "Shorter horizon friendly",
              "Cash needs discussion",
              "Advisor-guided"
            ]
          }
        ]
      },
      "estatePlanning": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774676522/smiling-middle-aged-couple-with-laptop-studying-documents-while-working-couch-home_650366-839_ay2t1b.avif",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678306/what-makes-a-contract-not-enforceable-scaled_1_eeu6xh.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479140/GettyImages-2194268868_Feature-Single-R_zmffb8.webp",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481684/istockphoto-658610090-612x612_gxlzth.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482724/calculator-1516869_1920_ipeyrd.webp",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678463/iStock-1198834050-scaled_dmpoo4.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678373/shutterstock_1403807051-min_c0utpi.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Planning and wealth insights.",
          "cards": [
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            },
            {
              "eyebrow": "Education", "title": "Student Loan Management", "body": "Understanding repayment options helps you manage debt while building your career and financial foundation."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Planning", "title": "Financial Planning Strategies", "body": "Goal-based planning, regular reviews, and flexible strategies help you adapt to life changes and market conditions."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Tax",
            "title": "Tax-aware planning layer",
            "badgeText": "",
            "metrics": [
              {
                "label": "FOCUS",
                "value": "Coordination"
              },
              {
                "label": "REVIEW",
                "value": "Annual"
              }
            ],
            "features": [
              "Gain and loss awareness",
              "Charitable giving timing",
              "Withholding and estimates discussion",
              "Work with your CPA"
            ]
          },
          {
            "smallTag": "Estate",
            "title": "Revocable living trust framework",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "REVIEW",
                "value": "Annual"
              },
              {
                "label": "SETUP",
                "value": "Guided"
              }
            ],
            "features": [
              "Pour-over will coordination",
              "Successor trustee roles",
              "Probate avoidance goals",
              "Attorney drafts documents"
            ]
          },
          {
            "smallTag": "Legacy",
            "title": "Heir and succession clarity",
            "badgeText": "",
            "metrics": [
              {
                "label": "HORIZON",
                "value": "Multi-gen"
              },
              {
                "label": "OUTPUT",
                "value": "Summary"
              }
            ],
            "features": [
              "Beneficiary consistency check",
              "Family meeting talking points",
              "Business succession hooks",
              "Scenarios for discussion"
            ]
          }
        ]
      }
    }
  },
  "assetManagement": {
    "useCases": {
      "globalEquitiesMandate": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678873/modern-meeting-room-tech-trends-scaled_ab5p1a.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739285/GettyImages-154401813_va7gte.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481868/360_F_283437738_PUdyvxvDJcvplpRu587FYqz9cyrH1IUG_gjk00t.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774231949/grow-small-business-1346252956_u9fcye.webp",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481684/istockphoto-658610090-612x612_gxlzth.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739285/GettyImages-154401813_va7gte.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739285/GettyImages-154401813_va7gte.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774679322/unnamed_1_lzm9oj.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Institutional investing insights.",
          "cards": [
            {
              "eyebrow": "Planning",
              "title": "Commercial Real Estate Trends",
              "body": "Expert perspectives on modern office and logistics trends shaping institutional portfolios."
            },
            {
              "eyebrow": "Market insight",
              "title": "Supporting Regional Development",
              "body": "Learn how commercial lending drives growth in high-opportunity urban corridors."
            },
            {
              "eyebrow": "Auto",
              "title": "Enterprise Expense Management",
              "body": "Optimize your corporate spending with integrated card programs and real-time tracking."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Scenario insight",
              "title": "Q3 Global Equity Outlook",
              "body": "Analyze the drivers behind international stock momentum and emerging growth."
            },
            {
              "eyebrow": "Scenario insight",
              "title": "Managing Geopolitical Risk",
              "body": "A deep dive into how shifting trade policies impact international equity valuations."
            },
            {
              "eyebrow": "Scenario insight",
              "title": "Quarterly Fund Summary",
              "body": "Review our latest fact sheet detailing fund performance, alpha, and sector allocations."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Developed",
            "title": "Institutional Equity Strategy",
            "badgeText": "",
            "metrics": [
              {
                "label": "STYLE",
                "value": "Active"
              },
              {
                "label": "REGION",
                "value": "Developed Intl"
              }
            ],
            "features": [
              "Bottom-up stock selection story",
              "Currency policy discussion",
              "Benchmark-relative risk framing",
              "Policy-aligned positioning"
            ]
          },
          {
            "smallTag": "Global",
            "title": "Sustainable Markets Portfolio",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "STYLE",
                "value": "Core"
              },
              {
                "label": "BENCH",
                "value": "Global benchmark"
              }
            ],
            "features": [
              "US and non-US blend",
              "Sector and factor controls",
              "Liquidity suited to plans",
              "Consultant due diligence"
            ]
          },
          {
            "smallTag": "Emerging",
            "title": "Emerging Growth Mandate",
            "badgeText": "",
            "metrics": [
              {
                "label": "ROLE",
                "value": "Satellite"
              },
              {
                "label": "VOL",
                "value": "Higher"
              }
            ],
            "features": [
              "Smaller policy weight typical",
              "Liquidity and capacity checks",
              "Governance considerations",
              "Not a recommendation"
            ]
          }
        ]
      },
      "coreFixedIncomeMandate": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678873/modern-meeting-room-tech-trends-scaled_ab5p1a.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739827/HowtoInvestinCorporateBondsGettyImages-1125626782-01c4aa86a81d471cb93a5c017029ee0d_xifjvn.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482228/SOSB0324009_1560x880_desktop_vpn0nd.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774481684/istockphoto-658610090-612x612_gxlzth.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482724/calculator-1516869_1920_ipeyrd.webp",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739684/gg2HHUFPh4moLTii4WfyFV_sbxlo7.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739730/image_947361300_tkaigt.webp",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739905/The-Allure-of-Tax-Free-Municipal-Bonds_zsyd8b.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Institutional investing insights.",
          "cards": [
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            },
            {
              "eyebrow": "Travel", "title": "Maximize Your Travel Rewards", "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Travel", "title": "Maximize Your Travel Rewards", "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder."
            },
            {
              "eyebrow": "Institutional", "title": "Institutional Insights", "body": "Strategic planning and the right financial products help you achieve your goals faster."
            },
            {
              "eyebrow": "Institutional", "title": "Institutional Insights", "body": "Strategic planning and the right financial products help you achieve your goals faster."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Stability",
            "title": "Short duration government tilt",
            "badgeText": "",
            "metrics": [
              {
                "label": "DURATION",
                "value": "2-3 yrs"
              },
              {
                "label": "CREDIT",
                "value": "Gov bias"
              }
            ],
            "features": [
              "Lower rate sensitivity story",
              "Liquidity emphasis",
              "Capital preservation framing",
              "Estimated metrics"
            ]
          },
          {
            "smallTag": "Core",
            "title": "Core investment grade",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "DURATION",
                "value": "Intermed."
              },
              {
                "label": "CREDIT",
                "value": "IG focus"
              }
            ],
            "features": [
              "Corporate and government mix",
              "Benchmark-aware process",
              "Income versus volatility trade-off",
              "Consultant DD"
            ]
          },
          {
            "smallTag": "Plus",
            "title": "Core-plus income",
            "badgeText": "",
            "metrics": [
              {
                "label": "YIELD",
                "value": "4.5%"
              },
              {
                "label": "RISK",
                "value": "Elevated"
              }
            ],
            "features": [
              "Selective below-IG allowance",
              "Drawdown discussion",
              "Fits some return-seeking sleeves",
              "Not for all policies"
            ]
          }
        ]
      },
      "sustainableInstitutional": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678873/modern-meeting-room-tech-trends-scaled_ab5p1a.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739942/ImageForArticle_21371_16457084545525256_wksfma.webp",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482046/managersbusiness_ntnvs5.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482724/calculator-1516869_1920_ipeyrd.webp",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482562/HanmiBank-Equipment-Leasing_pgktwd.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739942/ImageForArticle_21371_16457084545525256_wksfma.webp",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774740040/iStock-1199905534_gttxfe.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774740083/renewable-energy-technology-defined-solar-panels_uykgdu.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Institutional investing insights.",
          "cards": [
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            },
            {
              "eyebrow": "Travel", "title": "Maximize Your Travel Rewards", "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Institutional", "title": "Institutional Insights", "body": "Strategic planning and the right financial products help you achieve your goals faster."
            },
            {
              "eyebrow": "Institutional", "title": "Institutional Insights", "body": "Strategic planning and the right financial products help you achieve your goals faster."
            },
            {
              "eyebrow": "Institutional", "title": "Institutional Insights", "body": "Strategic planning and the right financial products help you achieve your goals faster."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Equity",
            "title": "Global ESG-integrated equity",
            "badgeText": "",
            "metrics": [
              {
                "label": "APPROACH",
                "value": "Integration"
              },
              {
                "label": "REPORTING",
                "value": "ESG"
              }
            ],
            "features": [
              "Materiality-focused research story",
              "Engagement where permitted",
              "Benchmark-relative risk",
              "Read prospectus before investing"
            ]
          },
          {
            "smallTag": "Real assets",
            "title": "Climate infrastructure sleeve",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "ROLE",
                "value": "Illiquid"
              },
              {
                "label": "TERM",
                "value": "Long"
              },
              {
                "label": "FIT",
                "value": "Satellite"
              }
            ],
            "features": [
              "Renewables and grid themes (illustrative)",
              "Liquidity and capacity constraints",
              "Low correlation story",
              "Due diligence required"
            ]
          },
          {
            "smallTag": "Fixed income",
            "title": "Green bond emphasis",
            "badgeText": "",
            "metrics": [
              {
                "label": "CREDIT",
                "value": "IG"
              },
              {
                "label": "DURATION",
                "value": "Intermed."
              }
            ],
            "features": [
              "Use-of-proceeds focus in selection",
              "Impact reporting varies by issuer",
              "Fits some liability-aware books",
              "Not a guarantee of impact"
            ]
          }
        ]
      },
      "liquidityInstitutional": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678873/modern-meeting-room-tech-trends-scaled_ab5p1a.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774739827/HowtoInvestinCorporateBondsGettyImages-1125626782-01c4aa86a81d471cb93a5c017029ee0d_xifjvn.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482364/istockphoto-1304746031-612x612_ccrxbd.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482562/HanmiBank-Equipment-Leasing_pgktwd.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774482228/SOSB0324009_1560x880_desktop_vpn0nd.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774740166/p2p-money-transfer-800x500_q8aazz.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774740212/intro-1666566558_j3c9iu.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774740336/Investments_What_happens_to_idle_cash_in_your_portfolio__Sweep_accounts_explained_c8bbml.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Institutional investing insights.",
          "cards": [
            {
              "eyebrow": "Market insight",
              "title": "Optimizing Supply Chain Finance",
              "body": "Financial strategies for logistics managers to maximize inventory and cash cycles."
            },
            {
              "eyebrow": "Market insight",
              "title": "Institutional Infrastructure Debt",
              "body": "Supporting large-scale industrial projects with tailored long-term financing solutions."
            },
            {
              "eyebrow": "Market insight",
              "title": "Global Business Scaling",
              "body": "Explore resources designed to help your enterprise scale efficiently across borders."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Scenario insight",
              "title": "Real-Time Cash Analytics",
              "body": "Gain visibility into your working capital with automated liquidity tracking and forecasting."
            },
            {
              "eyebrow": "Scenario insight",
              "title": "Liquidity in High-Rate Markets",
              "body": "Strategies for balancing immediate capital access with yield optimization for treasurers."
            },
            {
              "eyebrow": "Scenario insight",
              "title": "Overnight Sweep Account Model",
              "body": "See how our automated daily sweep ensures your excess capital earns interest while you sleep."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Cash",
            "title": "Automated Overnight Sweep",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "STABILITY",
                "value": "High"
              },
              {
                "label": "YIELD",
                "value": "Modest"
              }
            ],
            "features": [
              "Same-day liquidity typical",
              "Rule 2a-7 style framing",
              "Fits operational cash",
              "Read fund documents"
            ]
          },
          {
            "smallTag": "Ultra-short",
            "title": "Enhanced Cash Strategy",
            "badgeText": "",
            "metrics": [
              {
                "label": "DURATION",
                "value": "Very low"
              },
              {
                "label": "YIELD",
                "value": "Step-up"
              }
            ],
            "features": [
              "Slightly more yield than pure cash",
              "Mark-to-market fluctuation possible",
              "Minimum time horizon discussion",
              "Not FDIC insured"
            ]
          },
          {
            "smallTag": "Short IG",
            "title": "Institutional Money Market",
            "badgeText": "",
            "metrics": [
              {
                "label": "CREDIT",
                "value": "IG"
              },
              {
                "label": "VOL",
                "value": "Low–mod"
              }
            ],
            "features": [
              "Income over pure cash",
              "Rate and spread sensitivity",
              "Fits some reserve sleeves",
              "Policy limits apply"
            ]
          }
        ]
      }
    }
  },
  "insurance": {
    "useCases": {
      "auto": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479847/sports-car-insurance_mstufu.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479072/young-couple-renovating-home-and-dancing-in-living-room-EIF03304_wzfeup.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479444/Livery-Insurance-Close-up-Portrait-of-a-Woman-Driver-of-a-Car-Service-Smiling-at-the-Camera_vynex8.webp",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Financial planning and protection resources.",
          "cards": [
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            },
            {
              "eyebrow": "Travel", "title": "Maximize Your Travel Rewards", "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder."
            },
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Basic",
            "title": "State-aware essentials",
            "badgeText": "",
            "metrics": [
              {
                "label": "LIABILITY",
                "value": "Standard"
              },
              {
                "label": "DEDUCTIBLE",
                "value": "$750"
              }
            ],
            "features": [
              "Bodily injury and property damage",
              "Uninsured motorist options to discuss",
              "Digital ID cards",
              "Not a quote"
            ]
          },
          {
            "smallTag": "Balanced",
            "title": "Higher liability comfort",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "LIABILITY",
                "value": "Elevated"
              },
              {
                "label": "DEDUCTIBLE",
                "value": "$500"
              }
            ],
            "features": [
              "Increased liability limits",
              "Rental reimbursement option",
              "Accident forgiveness where available",
              "Licensed agent review"
            ]
          },
          {
            "smallTag": "Premium",
            "title": "Roadside & new-car extras",
            "badgeText": "",
            "metrics": [
              {
                "label": "ROADSIDE",
                "value": "Included"
              },
              {
                "label": "GLASS",
                "value": "No deductible"
              }
            ],
            "features": [
              "24/7 roadside and towing",
              "New car replacement discussion",
              "Gap coverage where applicable",
              "For illustration only"
            ]
          }
        ]
      },
      "home": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479639/exterior-cape-cod-house-mem-interiors-pc-r-brad-knipstein_d4kp5r.webp",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232099/homepage_personal_article_04_img_j78ibb.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479072/young-couple-renovating-home-and-dancing-in-living-room-EIF03304_wzfeup.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774677512/shutterstock_1414416203-600x400_sdr4my.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774741762/1000_F_430014652_BWwgK7W0VZztRlL24S13kii5aJh7XX6Z_me4qqa.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774741833/new-roof-buyer-discount-selling-home_tbaufv.png"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Insights and resources for homeowners.",
          "cards": [
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            },
            {
              "eyebrow": "Travel", "title": "Maximize Your Travel Rewards", "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder."
            },
            {
              "eyebrow": "Home", "title": "First-Time Homebuyer Essentials", "body": "From pre-approval to closing, understanding the mortgage process helps you make confident decisions."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Home Insurance", "title": "Understanding Coverage Options for New Homes", "body": "Replacement cost versus actual cash value affects how claims are paid and what you'll receive after a loss."
            },
            {
              "eyebrow": "Property", "title": "What Home Inspections Reveal About Risk", "body": "Roof age, electrical systems, and plumbing condition impact both insurability and premium costs."
            },
            {
              "eyebrow": "Claims", "title": "How Deductibles Affect Your Premium", "body": "Higher deductibles lower monthly costs but increase out-of-pocket expense when you file a claim."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Core",
            "title": "Dwelling essentials",
            "badgeText": "",
            "metrics": [
              {
                "label": "COVERAGE",
                "value": "Basic protection"
              },
              {
                "label": "DEDUCTIBLE",
                "value": "$1k"
              }
            ],
            "features": [
              "Dwelling and other structures",
              "Personal property baseline",
              "Loss of use discussion",
              "Renters parallel available"
            ]
          },
          {
            "smallTag": "Replacement",
            "title": "Replacement cost emphasis",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "REBUILD",
                "value": "125% covered"
              },
              {
                "label": "DEDUCTIBLE",
                "value": "$1.5k"
              }
            ],
            "features": [
              "Rebuild cost check-ins",
              "Water backup rider option",
              "Scheduled jewelry conversation",
              "Agent verifies details"
            ]
          },
          {
            "smallTag": "High value",
            "title": "Premier home program",
            "badgeText": "",
            "metrics": [
              {
                "label": "COVERAGE",
                "value": "$500k liability"
              },
              {
                "label": "DEDUCTIBLE",
                "value": "$2k"
              }
            ],
            "features": [
              "Higher liability coordination",
              "Flood and quake referrals",
              "Appraisal workflow",
              "Not available everywhere"
            ]
          }
        ]
      },
      "life": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774676522/smiling-middle-aged-couple-with-laptop-studying-documents-while-working-couch-home_650366-839_ay2t1b.avif",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479639/exterior-cape-cod-house-mem-interiors-pc-r-brad-knipstein_d4kp5r.webp",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479847/sports-car-insurance_mstufu.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774741643/0270_638156165196814228_e7ni19.avif",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774678008/633408_RET-107794_financial-tips-multiGeneration_vpHero_1200x628_i23bsh.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201705/retirement-income-planning-gi2190459889-hero_1.jpg_m30krr.webp"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Financial planning and family protection.",
          "cards": [
            {
              "eyebrow": "Travel", "title": "Maximize Your Travel Rewards", "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder."
            },
            {
              "eyebrow": "Investing", "title": "Understanding Market Trends", "body": "Economic indicators, sector rotation, and diversification help you make informed investment decisions."
            },
            {
              "eyebrow": "Auto", "title": "Financing Your Next Vehicle", "body": "Compare loan rates and terms to find the right balance between monthly payment and total interest cost."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Lending", "title": "Business Lending Options", "body": "Term loans, lines of credit, and equipment financing each serve different business needs and growth stages."
            },
            {
              "eyebrow": "Planning", "title": "Financial Planning Strategies", "body": "Goal-based planning, regular reviews, and flexible strategies help you adapt to life changes and market conditions."
            },
            {
              "eyebrow": "Insurance", "title": "Life Insurance for Families", "body": "Term and permanent life insurance options provide financial security for your loved ones."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Short bridge",
            "title": "10-year level term",
            "badgeText": "",
            "metrics": [
              {
                "label": "FACE",
                "value": "$500k"
              },
              {
                "label": "PREM",
                "value": "Illustrative"
              }
            ],
            "features": [
              "Income bridge during a loan payoff window",
              "Convertibility to discuss",
              "Exam may be required",
              "Subject to underwriting"
            ]
          },
          {
            "smallTag": "Family",
            "title": "20-year level term",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "FACE",
                "value": "$1M"
              },
              {
                "label": "PREM",
                "value": "Illustrative"
              }
            ],
            "features": [
              "Common horizon for young families",
              "Fixed premium during term",
              "Rider options with agent",
              "Beneficiary review"
            ]
          },
          {
            "smallTag": "Longer",
            "title": "30-year level term",
            "badgeText": "",
            "metrics": [
              {
                "label": "FACE",
                "value": "$750k"
              },
              {
                "label": "PREM",
                "value": "Illustrative"
              }
            ],
            "features": [
              "Longer mortgage alignment story",
              "Higher total premium vs shorter term",
              "Permanent options separate conversation",
              "Final rates via underwriting"
            ]
          }
        ]
      },
      "bundleHomeAuto": {
        "heroAssets": {
          "coldHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774233421/how-to-choose-IRA-investments-2x-jpg_ybft7q.jpg",
          "warmHero": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774479847/sports-car-insurance_mstufu.jpg",
          "insight1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774472484/confident-student-in-shared-space-with-laptop_collagestyle_zeay8z.avif",
          "insight2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201707/Sixty-and-Me_How-to-Live-in-Luxury-in-Retirement_-No-Matter-Your-Budget_xcg3ws.jpg",
          "insight3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774201482/Travel-Credit-Card_qz9owg.jpg",
          "warmTile1": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774741705/life-insurance_cets0p.jpg",
          "warmTile2": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774232320/property-insurance_bgwmxn.jpg",
          "warmTile3": "https://res.cloudinary.com/dfx98jgdc/image/upload/v1774202333/auto-insurance-insurance-options_wtctvt.png"
        },
        "homeMarketInsights": {
          "sectionSubtitle": "Protection and savings strategies.",
          "cards": [
            {
              "eyebrow": "Education", "title": "Student Loan Management", "body": "Understanding repayment options helps you manage debt while building your career and financial foundation."
            },
            {
              "eyebrow": "Retirement", "title": "Planning for Your Golden Years", "body": "Start retirement savings early to give compound interest decades to work in your favor."
            },
            {
              "eyebrow": "Travel", "title": "Maximize Your Travel Rewards", "body": "Premium travel cards turn everyday spending into dream vacations with points that work harder."
            }
          ]
        },
        "warmMarketInsights": {
          "cards": [
            {
              "eyebrow": "Life Insurance", "title": "Term Life Coverage for Growing Families", "body": "Term policies provide affordable protection during peak earning years when dependents rely on your income."
            },
            {
              "eyebrow": "Home", "title": "Protecting Your Property Investment", "body": "Comprehensive homeowners coverage shields your largest asset from fire, weather, theft, and liability claims."
            },
            {
              "eyebrow": "Auto", "title": "Choosing the Right Auto Coverage Limits", "body": "Liability limits protect your assets if you're at fault, while collision and comprehensive cover your vehicle."
            }
          ]
        },
        "cards": [
          {
            "smallTag": "Core Coverage",
            "title": "Essential Bundle",
            "badgeText": "",
            "metrics": [
              {
                "label": "SAVINGS",
                "value": "10%"
              },
              {
                "label": "DEDUCTIBLE",
                "value": "Split"
              }
            ],
            "features": [
              "State minimum auto limits",
              "Standard dwelling protection",
              "Digital claims tracking",
              "Affordable monthly premiums"
            ]
          },
          {
            "smallTag": "Recommended",
            "title": "Enhanced Protection Bundle",
            "badgeText": "Best Match",
            "metrics": [
              {
                "label": "SAVINGS",
                "value": "15%"
              },
              {
                "label": "DEDUCTIBLE",
                "value": "Single"
              }
            ],
            "features": [
              "Single deductible for shared events",
              "Replacement cost plus for home",
              "Accident forgiveness",
              "24/7 roadside assistance"
            ]
          },
          {
            "smallTag": "High Limit",
            "title": "Premier Shield Bundle",
            "badgeText": "",
            "metrics": [
              {
                "label": "SAVINGS",
                "value": "18%"
              },
              {
                "label": "UMBRELLA",
                "value": "Included"
              }
            ],
            "features": [
              "Maximum liability limits",
              "$1M Personal Umbrella included",
              "Valuable items rider",
              "Priority concierge claims support"
            ]
          }
        ]
      }
    }
  }
};

const ADAPTIVE_CUSTOM_RECORD = {
  coldHeroEyebrow: "",
  coldHeroHeading: "",
  coldHeroParagraph1: "",
  coldHeroParagraph2: "",
  homepageCtaText: "",
  intentTriggerText: "",
  homeMarketInsights: { sectionSubtitle: "", cards: [] },
  warmInsights: [],
  categoryPage: {},
  useCases: { custom: { name: "Custom", cards: [] } },
};

const DEFAULT_ADAPTIVE_HERO_IMAGE =
  "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1600&q=80";
const DEFAULT_ADAPTIVE_NAV_LOGO =
  "https://cumulusfinserv-ad61ddfc9e8c.herokuapp.com/images/cumulus-logo.png";
const DEFAULT_ADAPTIVE_COLD_HERO_IMAGE =
  "https://images.unsplash.com/photo-1565514020179-026b92b84bb6?auto=format&fit=crop&w=800&q=80";
const DEFAULT_ADAPTIVE_INSIGHT_IMG_1 =
  "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=900&q=80";
const DEFAULT_ADAPTIVE_INSIGHT_IMG_2 =
  "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=900&q=80";
const DEFAULT_ADAPTIVE_INSIGHT_IMG_3 =
  "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=900&q=80";

/* ===== functions ===== */
function resolveCumulusAssetUrl(rel) {
  if (rel == null || rel === "") return "";
  const s = String(rel).trim();
  if (/^https?:\/\//i.test(s)) return s;
  try {
    const path = s.replace(/^\.\//, "");
    const encoded = encodeURI(path);
    return new URL(encoded, window.location.href).href;
  } catch {
    return s;
  }
}

function mergeCategoryPageWithCumulus(industryKey, baseCategoryPage) {
  const pack = CUMULUS_ASSET_LIBRARY[industryKey] || CUMULUS_ASSET_LIBRARY.retailBanking;
  if (!pack || !baseCategoryPage) return baseCategoryPage;
  const cold = resolveCumulusAssetUrl(pack.coldHero);
  const warm = resolveCumulusAssetUrl(pack.warmHero);
  return {
    ...baseCategoryPage,
    ...(cold ? { heroBgImage: cold } : {}),
    ...(warm ? { whyChooseUsImage: warm } : {}),
  };
}

function getResolvedHeroAssetPack(industryKey, useCaseRecord) {
  const base = CUMULUS_ASSET_LIBRARY[industryKey] || CUMULUS_ASSET_LIBRARY.retailBanking;
  const over = (useCaseRecord && useCaseRecord.heroAssets) || {};
  const pick = (k) => {
    const v = over[k];
    const t = v != null ? String(v).trim() : "";
    if (t) return t;
    const b = base[k];
    return b != null ? String(b).trim() : "";
  };
  const coldBase = base.coldHero != null ? String(base.coldHero).trim() : "";
  const coldFromCase = over.coldHero != null ? String(over.coldHero).trim() : "";
  const coldHero = coldFromCase || coldBase;

  const warmHero = pick("warmHero");
  const insight1 = pick("insight1");
  const insight2 = pick("insight2");
  const insight3 = pick("insight3");

  const wt1 = over.warmTile1 != null ? String(over.warmTile1).trim() : "";
  const wt2 = over.warmTile2 != null ? String(over.warmTile2).trim() : "";
  const wt3 = over.warmTile3 != null ? String(over.warmTile3).trim() : "";
  const warmTile1 = wt1 || warmHero;
  const warmTile2 = wt2 || insight2;
  const warmTile3 = wt3 || insight3;

  return {
    coldHero,
    warmHero,
    insight1,
    insight2,
    insight3,
    warmTile1,
    warmTile2,
    warmTile3,
  };
}

function mergeHomeMarketInsightsForUseCase(industryRecord, useCaseRecord) {
  const baseHm =
    industryRecord.homeMarketInsights && typeof industryRecord.homeMarketInsights === "object"
      ? industryRecord.homeMarketInsights
      : {};
  const overHm =
    useCaseRecord.homeMarketInsights && typeof useCaseRecord.homeMarketInsights === "object"
      ? useCaseRecord.homeMarketInsights
      : {};
  const bc = Array.isArray(baseHm.cards) ? baseHm.cards : [];
  const oc = Array.isArray(overHm.cards) ? overHm.cards : [];
  const cards = [0, 1, 2].map((i) => ({ ...(bc[i] || {}), ...(oc[i] || {}) }));
  const sub =
    overHm.sectionSubtitle != null && String(overHm.sectionSubtitle).trim()
      ? String(overHm.sectionSubtitle).trim()
      : baseHm.sectionSubtitle || "";
  return { sectionSubtitle: sub, cards };
}

function mergeWarmMarketInsightsForUseCase(industryRecord, useCaseRecord) {
  const base = Array.isArray(industryRecord.warmInsights) ? industryRecord.warmInsights : [];
  const oc =
    useCaseRecord.warmMarketInsights && Array.isArray(useCaseRecord.warmMarketInsights.cards)
      ? useCaseRecord.warmMarketInsights.cards
      : [];
  return [0, 1, 2].map((i) => ({ ...(base[i] || {}), ...(oc[i] || {}) }));
}

function applyAdaptiveMatrixOverrides() {
  Object.entries(ADAPTIVE_MATRIX_OVERRIDES).forEach(([industryKey, industryOverride]) => {
    const industry = ADAPTIVE_WEB_COPY_BY_SUB_INDUSTRY[industryKey];
    if (!industry || !industry.useCases) return;
    Object.entries(industryOverride.useCases || {}).forEach(([useCaseKey, useOverride]) => {
      const useCase = industry.useCases[useCaseKey];
      if (!useCase) return;
      if (useOverride.heroAssets) useCase.heroAssets = { ...(useCase.heroAssets || {}), ...useOverride.heroAssets };
      if (useOverride.cards && Array.isArray(useOverride.cards)) {
        const baseCards = Array.isArray(useCase.cards) ? useCase.cards : [];
        useCase.cards = useOverride.cards.map((c, idx) => ({
          ...(baseCards[idx] || {}),
          ...c,
          metrics: Array.isArray(c.metrics) ? c.metrics : (baseCards[idx]?.metrics || []),
          features: Array.isArray(c.features) ? c.features : (baseCards[idx]?.features || []),
        }));
      }
      if (useOverride.homeMarketInsights) useCase.homeMarketInsights = useOverride.homeMarketInsights;
      if (useOverride.warmMarketInsights) useCase.warmMarketInsights = useOverride.warmMarketInsights;
    });
  });
}

function getAdaptiveIndustryRecord(industryKey) {
  if (industryKey === "custom") return ADAPTIVE_CUSTOM_RECORD;
  return ADAPTIVE_WEB_COPY_BY_SUB_INDUSTRY[industryKey] || ADAPTIVE_WEB_COPY_BY_SUB_INDUSTRY.retailBanking;
}

function resolveAdaptiveUseCaseKey(industryRecord, requestedKey) {
  const uc = industryRecord.useCases;
  if (!uc || typeof uc !== "object") return "default";
  const keys = Object.keys(uc);
  if (keys.length === 0) return "default";
  if (requestedKey && uc[requestedKey]) return requestedKey;
  return keys[0];
}

function getAdaptiveUseCaseBundle(formData) {
  const ind =
    (formData && formData.adaptiveWebSubIndustry) ||
    document.getElementById("adaptiveWebSubIndustry")?.value ||
    "retailBanking";
  const industry = getAdaptiveIndustryRecord(ind);
  const requested =
    (formData && formData.adaptiveWebSubUseCase) ||
    document.getElementById("adaptiveWebSubUseCase")?.value ||
    "";
  const useKey = resolveAdaptiveUseCaseKey(industry, requested);
  const useCase = industry.useCases?.[useKey] || {};
  return { ind, industry, useKey, useCase };
}

function escapeHtmlForAdaptive(s) {
  if (s == null) return "";
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function sanitizeAdaptiveHexColor(value, fallback) {
  const t = (value || "").trim();
  if (/^#[0-9A-Fa-f]{6}$/.test(t)) return t;
  return fallback;
}

function getAdaptiveWebAgentIconSrc() {
  try {
    return new URL("agentforce-astro-agent.png", window.location.href).href;
  } catch {
    return "agentforce-astro-agent.png";
  }
}

function escapeHtmlAttributeValue(s) {
  return String(s).replace(/&/g, "&amp;").replace(/"/g, "&quot;");
}

function getAdaptivePersona(formData) {
  const pick = (dataKey, elId, fallback) => {
    if (formData && formData[dataKey] != null && String(formData[dataKey]).trim()) {
      return String(formData[dataKey]).trim();
    }
    const v = document.getElementById(elId)?.value;
    if (v != null && String(v).trim()) return String(v).trim();
    return fallback;
  };
  return {
    firstName: pick("adaptivePersonaFirstName", "adaptivePersonaFirstName", "Rachel"),
    lastName: pick("adaptivePersonaLastName", "adaptivePersonaLastName", "Morris"),
    email: pick("adaptivePersonaEmail", "adaptivePersonaEmail", "rmorris@example.com"),
    phone: pick("adaptivePersonaPhone", "adaptivePersonaPhone", "555-0198"),
    company: pick("adaptivePersonaCompany", "adaptivePersonaCompany", "Acme Corp"),
    zipCode: pick("adaptivePersonaZip", "adaptivePersonaZip", "94105"),
    brandName: pick("adaptiveBrandName", "adaptiveBrandName", "Cumulus Bank"),
    agentName: pick("adaptiveAgentName", "adaptiveAgentName", "Penny"),
  };
}

function interpolateAdaptivePersona(str, persona) {
  if (str == null) return "";
  const bn = persona.brandName != null ? String(persona.brandName) : "";
  const an = persona.agentName != null ? String(persona.agentName) : "Penny";
  return String(str)
    .replace(/\[\[CUSTOMER_FIRST_NAME\]\]/g, persona.firstName)
    .replace(/\$\{firstName\}/g, persona.firstName)
    .replace(/\$\{lastName\}/g, persona.lastName)
    .replace(/\$\{email\}/g, persona.email)
    .replace(/\$\{phone\}/g, persona.phone)
    .replace(/\$\{company\}/g, persona.company)
    .replace(/\$\{zipCode\}/g, persona.zipCode)
    .replace(/\$\{brandName\}/g, bn)
    .replace(/\$\{agentName\}/g, an)
    // Legacy default copy hardcodes "Penny"; retarget to the chosen agent name.
    .replace(/\bPenny\b/g, an);
}

function buildCategoryPageHtml(story, personaArg) {
  const persona = personaArg || getAdaptivePersona(null);
  const bn = String(persona.brandName ?? "");
  const rBrand = (t) =>
    String(t ?? "")
      .replace(/\[\[BRAND_NAME\]\]/g, bn)
      .replace(/\$\{brandName\}/g, bn);
  const escCat = (t) => escapeHtmlForAdaptive(interpolateAdaptivePersona(rBrand(t), persona));
  const esc = escapeHtmlForAdaptive;
  const cp = story.categoryPage || {};
  const whyImg = String(cp.whyChooseUsImage || "").trim();
  const services = Array.isArray(cp.services) ? cp.services : [];
  const svcHtml = services
    .map(
      (s) => `<div class="category-service-card min-w-0 rounded-2xl border border-slate-200 bg-white p-5 shadow-sm ring-1 ring-slate-100 sm:p-6 md:p-8">
<div class="category-service-icon-wrap mb-3 flex h-11 w-11 shrink-0 items-center justify-center rounded-xl sm:mb-4 sm:h-12 sm:w-12" style="background-color: color-mix(in srgb, var(--brand) 10%, transparent); color: var(--brand);">
<i class="fas ${esc(s.iconClass || "fa-layer-group")} text-lg transition-colors duration-300 sm:text-xl" aria-hidden="true"></i>
</div>
<h3 class="text-balance text-base font-bold text-slate-900 sm:text-lg">${escCat(s.title || "")}</h3>
<p class="mt-2 text-sm leading-relaxed text-slate-600 sm:mt-3">${escCat(s.description || "")}</p>
</div>`
    )
    .join("");
  return `<div class="category-page-inner min-w-0 max-w-full overflow-x-hidden bg-white text-slate-900">
<section id="cat-hero" class="relative flex min-h-[min(52vh,420px)] w-full items-center justify-center overflow-hidden px-4 py-16 sm:px-6 sm:py-20 md:min-h-[520px] md:px-8 md:py-32 scroll-mt-[72px]">
<div class="absolute inset-0 z-[1] bg-slate-900/65" aria-hidden="true"></div>
<div class="absolute inset-0 z-0" style="background: var(--category-hero-banner-bg);" aria-hidden="true"></div>${
    String(cp.heroBgImage || "").trim()
      ? `\n<div class="absolute inset-0 z-0 bg-cover bg-center" style="background-image: url('${escapeHtmlAttributeValue(String(cp.heroBgImage).trim())}');" aria-hidden="true"></div>`
      : ""
  }
<div class="relative z-10 mx-auto max-w-4xl px-2 text-center sm:px-4">
<h1 class="text-balance text-2xl font-bold tracking-tight text-white sm:text-3xl md:text-4xl lg:text-5xl">${escCat(cp.catHeroTitle || "")}</h1>
<p class="mt-4 text-base leading-relaxed text-white/90 sm:mt-5 sm:text-lg md:text-xl">${escCat(cp.catHeroSubtitle || "")}</p>
</div>
</section>
<section id="cat-core-services" class="scroll-mt-[72px] border-t border-slate-200 bg-white py-12 sm:py-16 md:py-24">
<div class="mx-auto max-w-7xl min-w-0 px-4 sm:px-6 md:px-10 lg:px-14 xl:px-20">
<h2 class="text-xl font-bold text-slate-900 sm:text-2xl md:text-3xl">${escCat(cp.coreServicesHeading || "Core services")}</h2>
<div class="mt-8 grid grid-cols-1 gap-6 sm:mt-10 sm:gap-8 md:grid-cols-3 md:gap-8 lg:gap-10">${svcHtml}</div>
</div>
</section>
<section id="cat-why-us" class="scroll-mt-[72px] border-t border-slate-200 bg-slate-50 py-12 sm:py-16 md:py-24">
<div class="mx-auto max-w-7xl min-w-0 px-4 sm:px-6 md:px-10 lg:px-14 xl:px-20">
<div class="grid grid-cols-1 gap-10 lg:grid-cols-2 lg:items-center lg:gap-14 xl:gap-16">
<div class="order-2 min-w-0 lg:order-1">
<h2 class="text-balance text-xl font-bold text-slate-900 sm:text-2xl md:text-3xl">${escCat(cp.whyChooseUsTitle || "")}</h2>
<p class="mt-4 text-sm leading-relaxed text-slate-600 sm:mt-5 sm:text-base md:text-lg">${escCat(cp.whyChooseUsText || "")}</p>
</div>
<div class="order-1 min-w-0 lg:order-2">
<div class="overflow-hidden rounded-2xl shadow-lg ring-1 ring-slate-200">
<img src="${escapeHtmlAttributeValue(whyImg)}" alt="" class="h-auto min-h-[200px] w-full object-cover sm:min-h-[240px] md:min-h-[300px] lg:min-h-[320px]" width="1200" height="800" loading="lazy" />
</div>
</div>
</div>
</div>
</section>
<section id="cat-insights" class="scroll-mt-[72px] border-t border-slate-200 bg-white py-12 pb-20 sm:py-16 sm:pb-24 md:py-24 md:pb-28">
<div class="mx-auto max-w-7xl min-w-0 px-4 sm:px-6 md:px-10 lg:px-14 xl:px-14 xl:px-20">
<h2 class="text-balance text-xl font-bold text-slate-900 sm:text-2xl md:text-3xl">${escCat(cp.marketInsightsHeading || "Market insights & resources")}</h2>
<p class="mt-2 max-w-2xl text-sm text-slate-600 sm:text-base">${escCat(
    String(cp.marketInsightsIntro || "").trim() ||
      "Short reads on themes that matter in this line of business. When you want next steps for your situation, open the chat and ask Penny—your ${brandName} assistant in this demo."
  )}</p>
<div class="mt-8 grid grid-cols-1 gap-6 sm:mt-10 sm:gap-8 md:grid-cols-2 md:gap-8 lg:gap-10">
<article class="category-insight-card flex min-h-[200px] flex-col rounded-2xl border border-slate-200 bg-slate-50/80 p-5 ring-1 ring-slate-100 sm:min-h-[220px] sm:p-8">
<div class="category-insight-eyebrow text-xs font-bold uppercase tracking-wider text-[#008b7d]">${esc("Insight")}</div>
<h3 class="category-insight-title mt-2 text-balance text-lg font-semibold text-slate-900 sm:text-xl">${escCat(cp.article1Title || "")}</h3>
<div class="mt-4 flex-1"></div>
<span class="category-insight-cta mt-4 inline-block text-sm font-semibold text-[#008b7d] sm:mt-6">${escCat("Ask ${agentName} in chat →")}</span>
</article>
<article class="category-insight-card flex min-h-[200px] flex-col rounded-2xl border border-slate-200 bg-slate-50/80 p-5 ring-1 ring-slate-100 sm:min-h-[220px] sm:p-8">
<div class="category-insight-eyebrow text-xs font-bold uppercase tracking-wider text-[#008b7d]">${esc("Insight")}</div>
<h3 class="category-insight-title mt-2 text-balance text-lg font-semibold text-slate-900 sm:text-xl">${escCat(cp.article2Title || "")}</h3>
<div class="mt-4 flex-1"></div>
<span class="category-insight-cta mt-4 inline-block text-sm font-semibold text-[#008b7d] sm:mt-6">${escCat("Ask ${agentName} in chat →")}</span>
</article>
</div>
</div>
</section>
</div>`;
}

function buildAdaptiveCardsFromMatrixInputs(fallbackCards) {
  const fb = Array.isArray(fallbackCards) ? fallbackCards : [];
  let chosenRec = -1;
  for (let i = 1; i <= 3; i++) {
    if (document.getElementById(`card${i}_bestMatch`)?.checked) {
      chosenRec = i - 1;
      break;
    }
  }
  if (chosenRec < 0) {
    chosenRec = fb.findIndex((c) => c.recommended);
    if (chosenRec < 0) chosenRec = 1;
  }
  const gv = (id, fallback) => {
    const el = document.getElementById(id);
    if (!el) return fallback;
    const t = (el.value != null ? String(el.value) : "").trim();
    return t || fallback;
  };
  const out = [];
  for (let i = 0; i < 3; i++) {
    const n = i + 1;
    const p = `card${n}_`;
    const fbc = fb[i] || {};
    const metrics = [];
    for (let m = 1; m <= 3; m++) {
      const lab = gv(
        `${p}m${m}_label`,
        (fbc.metrics && fbc.metrics[m - 1] && fbc.metrics[m - 1].label) || ""
      );
      const val = gv(
        `${p}m${m}_value`,
        (fbc.metrics && fbc.metrics[m - 1] && fbc.metrics[m - 1].value != null
          ? String(fbc.metrics[m - 1].value)
          : "") || ""
      );
      if (lab || val) metrics.push({ label: lab, value: val });
    }
    const features = [];
    for (let f = 1; f <= 4; f++) {
      const t = gv(`${p}f${f}`, (fbc.features && fbc.features[f - 1]) || "");
      if (t) features.push(t);
    }
    out.push({
      recommended: i === chosenRec,
      badgeText: gv(`${p}badgeText`, fbc.badgeText || "Best Match"),
      smallTag: gv(`${p}tag`, fbc.smallTag || "Category"),
      title: gv(`${p}title`, fbc.title || ""),
      iconClass: gv(`${p}icon`, fbc.iconClass || "fa-layer-group"),
      metrics: metrics.length ? metrics : fbc.metrics || [],
      features: features.length ? features : fbc.features || [],
      bundleText: gv(`${p}bundle`, fbc.bundleText || ""),
      ctaLabel: gv(`${p}cta`, fbc.ctaLabel || "Learn more"),
    });
  }
  return out;
}

function buildAdaptiveCardsGridHtml(cards, personaArg) {
  const persona = personaArg || getAdaptivePersona(null);
  const bn = String(persona.brandName ?? "");
  const rBrand = (t) =>
    String(t ?? "")
      .replace(/\[\[BRAND_NAME\]\]/g, bn)
      .replace(/\$\{brandName\}/g, bn);
  const escCard = (t) => escapeHtmlForAdaptive(interpolateAdaptivePersona(rBrand(t), persona));
  const esc = escapeHtmlForAdaptive;
  const list = Array.isArray(cards) ? cards : [];
  let html = '<div class="floating-cards-container items-stretch">';
  list.forEach((card) => {
    const rec = !!card.recommended;
    const borderStyle = rec
      ? ' style="border-width:2px;border-color:var(--brand);box-shadow:0 20px 60px rgba(0,0,0,0.18);"'
      : "";
    const badgeLabel = escCard(card.badgeText || "Best Match");
    const bundleRaw = String(card.bundleText || card.highlight || "").trim();

    html += `<div class="solution-card flex flex-col h-full${rec ? " solution-card-recommended" : ""}"${borderStyle}>`;
    if (rec) {
      html += `<div class="recommended-badge"><i class="fas fa-star" aria-hidden="true"></i><span>${badgeLabel}</span></div>`;
    }

    html += '<div class="flex flex-col flex-grow min-h-0">';
    html += `<div class="card-header shrink-0${rec ? " pr-24 sm:pr-28" : ""}">`;
    html += '<div class="flex items-start justify-between gap-3 mb-1"><div class="flex items-center min-w-0">';
    html += `<div class="solution-icon shrink-0" style="background-color: color-mix(in srgb, var(--brand) 15%, transparent); color: var(--brand);">`;
    html += `<i class="fas ${esc(card.iconClass || "fa-layer-group")}" aria-hidden="true"></i>`;
    html += '</div><div class="ml-3 min-w-0">';
    html += `<p class="text-xs uppercase tracking-wide font-semibold ${rec ? "text-brand" : "text-gray-500"} mb-1">${escCard(
      card.smallTag || "Category"
    )}</p>`;
    html += `<h3 class="text-xl font-bold text-gray-900 leading-snug">${escCard(card.title)}</h3>`;
    html += "</div></div></div></div>";

    html += '<div class="card-body flex flex-col flex-grow pt-0 min-h-0">';
    html += '<div class="flex flex-col flex-grow min-h-0">';
    html += '<div class="metrics-grid">';
    const metricsRow = (Array.isArray(card.metrics) ? card.metrics : []).slice(0, 3);
    metricsRow.forEach((m) => {
      html += '<div class="metric-item">';
      html += `<div class="metric-label">${escCard(m.label)}</div>`;
      html += `<div class="metric-value-row ${rec ? "text-brand" : "text-gray-900"}">`;
      html += `<span class="metric-value-core">${escCard(m.value)}</span>`;
      if (m.unit) {
        html += `<span class="metric-unit">${escCard(m.unit)}</span>`;
      }
      html += "</div></div>";
    });
    html += '</div><div class="divider"></div><div class="features-section">';
    html += '<h4 class="features-title">Key features</h4><ul class="features-list">';
    const feats = (Array.isArray(card.features) ? card.features : []).slice(0, 4);
    feats.forEach((feat) => {
      const iconCls = rec ? "text-brand" : "text-gray-400";
      html += `<li class="feature-item"><i class="fas fa-check-circle ${iconCls}" aria-hidden="true"></i><span>${escCard(
        feat
      )}</span></li>`;
    });
    html += "</ul></div>";
    if (bundleRaw) {
      html += `<div class="bundle-highlight"><i class="fas fa-lightbulb text-brand" aria-hidden="true"></i><span>${escCard(
        bundleRaw
      )}</span></div>`;
    }
    html += "</div>";
    html += '<div class="mt-auto pt-4 w-full shrink-0">';
    html += `<button type="button" class="card-cta-btn mt-0">${escCard(card.ctaLabel || "Learn more")}</button>`;
    html += "</div></div></div></div>";
  });
  html += "</div>";
  return html;
}

function getMergedAdaptiveStory(formData) {
  const { ind, industry, useKey, useCase } = getAdaptiveUseCaseBundle(formData);
  const pack = getResolvedHeroAssetPack(ind, useCase);
  const g = (id, fallback) => {
    const v = document.getElementById(id)?.value;
    const t = (v != null ? String(v) : "").trim();
    return t || fallback;
  };
  const wMerged = mergeWarmMarketInsightsForUseCase(industry, useCase);
  const w0 = wMerged[0] || {};
  const w1 = wMerged[1] || {};
  const w2 = wMerged[2] || {};
  const hm = mergeHomeMarketInsightsForUseCase(industry, useCase);
  const hmc = Array.isArray(hm.cards) ? hm.cards : [];
  const hc = (i) => hmc[i] || {};
  const cp = mergeCategoryPageWithCumulus(ind, industry.categoryPage);
  return {
    categoryPage: {
      // Category (detail) page hero image: honor the explicit field, else the
      // industry/use-case asset pack (cp.heroBgImage).
      heroBgImage: g("catHeroImageUrl", cp.heroBgImage || ""),
      catHeroTitle: g("catHeroTitle", cp.catHeroTitle || ""),
      catHeroSubtitle: g("catHeroSubtitle", cp.catHeroSubtitle || ""),
      coreServicesHeading: g("catCoreServicesHeading", "Core services"),
      services: [
        {
          iconClass: g("catService1Icon", cp.services?.[0]?.iconClass || "fa-layer-group"),
          title: g("catService1Title", cp.services?.[0]?.title || ""),
          description: g("catService1Desc", cp.services?.[0]?.description || ""),
        },
        {
          iconClass: g("catService2Icon", cp.services?.[1]?.iconClass || "fa-layer-group"),
          title: g("catService2Title", cp.services?.[1]?.title || ""),
          description: g("catService2Desc", cp.services?.[1]?.description || ""),
        },
        {
          iconClass: g("catService3Icon", cp.services?.[2]?.iconClass || "fa-layer-group"),
          title: g("catService3Title", cp.services?.[2]?.title || ""),
          description: g("catService3Desc", cp.services?.[2]?.description || ""),
        },
      ],
      whyChooseUsTitle: g("catWhyTitle", cp.whyChooseUsTitle || ""),
      whyChooseUsText: g("catWhyText", cp.whyChooseUsText || ""),
      whyChooseUsImage: g("catWhyImageUrl", cp.whyChooseUsImage || ""),
      marketInsightsHeading: g("catInsightsHeading", "Market insights & resources"),
      marketInsightsIntro: g("catInsightsIntro", cp.marketInsightsIntro || ""),
      article1Title: g("catArticle1Title", cp.article1Title || ""),
      article2Title: g("catArticle2Title", cp.article2Title || ""),
    },
    homepageCtaText: industry.homepageCtaText,
    adaptiveWebSubIndustry: ind,
    adaptiveWebSubUseCase: useKey,
    vanillaHeroTitle: g("vanillaHeroTitle", useCase.vanillaHeroTitle),
    vanillaHeroSubtext: g("vanillaHeroSubtext", useCase.vanillaHeroSubtext),
    intentTriggerText: g("intentTriggerText", industry.homepageCtaText || industry.intentTriggerText),
    userIntentString: g("userIntentString", useCase.userIntentString || ""),
    agentChatMessage: g("agentChatMessage", useCase.agentChatMessage || ADAPTIVE_GENERIC_AGENT_GREETING),
    chatWidgetTitle: g("chatWidgetTitle", useCase.chatWidgetTitle),
    agentAdaptiveResponse: g("agentAdaptiveResponse", useCase.agentAdaptiveResponse),
    adaptiveOverlayTitle: g("adaptiveOverlayTitle", useCase.adaptiveOverlayTitle),
    adaptiveOverlaySubtitle: g("adaptiveOverlaySubtitle", useCase.adaptiveOverlaySubtitle),
    adaptiveFooterNote: g("adaptiveFooterNote", useCase.adaptiveFooterNote),
    landingPageTitle: g("landingPageTitle", useCase.landingPageTitle),
    landingPageSubtitle: g("landingPageSubtitle", useCase.landingPageSubtitle),
    homeInsightsHeading: g("homeInsightsHeading", "Market Insights"),
    homeInsightsSubtitle: g("homeInsightsSubtitle", hm.sectionSubtitle || ""),
    homeInsight1Eyebrow: g("homeInsight1Eyebrow", hc(0).eyebrow || ""),
    homeInsight1Title: g("homeInsight1Title", hc(0).title || ""),
    homeInsight1Body: g("homeInsight1Body", hc(0).body || ""),
    homeInsight2Eyebrow: g("homeInsight2Eyebrow", hc(1).eyebrow || ""),
    homeInsight2Title: g("homeInsight2Title", hc(1).title || ""),
    homeInsight2Body: g("homeInsight2Body", hc(1).body || ""),
    homeInsight3Eyebrow: g("homeInsight3Eyebrow", hc(2).eyebrow || ""),
    homeInsight3Title: g("homeInsight3Title", hc(2).title || ""),
    homeInsight3Body: g("homeInsight3Body", hc(2).body || ""),
    coldHeroEyebrow: g("coldHeroEyebrow", industry.coldHeroEyebrow || "Life simplified"),
    coldHeroHeading: g("coldHeroHeading", industry.coldHeroHeading || "Comprehensive financial solutions for every stage of life."),
    coldHeroParagraph1: g("coldHeroParagraph1", industry.coldHeroParagraph1 || ""),
    coldHeroParagraph2: g("coldHeroParagraph2", industry.coldHeroParagraph2 || ""),
    warmInsight1Img: g("warmInsight1Img", w0.image || pack.warmTile1 || DEFAULT_ADAPTIVE_INSIGHT_IMG_1),
    warmInsight1Title: g("warmInsight1Title", w0.title || ""),
    warmInsight1Eyebrow: g("warmInsight1Eyebrow", w0.eyebrow || ""),
    warmInsight1Body: g("warmInsight1Body", w0.body || ""),
    warmInsight2Img: g("warmInsight2Img", w1.image || pack.warmTile2 || DEFAULT_ADAPTIVE_INSIGHT_IMG_2),
    warmInsight2Title: g("warmInsight2Title", w1.title || ""),
    warmInsight2Eyebrow: g("warmInsight2Eyebrow", w1.eyebrow || ""),
    warmInsight2Body: g("warmInsight2Body", w1.body || ""),
    warmInsight3Img: g("warmInsight3Img", w2.image || pack.warmTile3 || DEFAULT_ADAPTIVE_INSIGHT_IMG_3),
    warmInsight3Title: g("warmInsight3Title", w2.title || ""),
    warmInsight3Eyebrow: g("warmInsight3Eyebrow", w2.eyebrow || ""),
    warmInsight3Body: g("warmInsight3Body", w2.body || ""),
    mockProfile: useCase.mockProfile,
    cards: buildAdaptiveCardsFromMatrixInputs(useCase.cards),
  };
}

function applyAdaptiveWebTemplateReplacements(html, formData) {
  const primary = sanitizeAdaptiveHexColor(formData.adaptivePrimaryColor, "#0176d3");
  const accent = sanitizeAdaptiveHexColor(formData.adaptiveAccentColor, "#00ac5b");
  const heroGradientColor = sanitizeAdaptiveHexColor(formData.heroGradientColor, "#005fb2");
  const heroGradientColor2 = sanitizeAdaptiveHexColor(formData.heroGradientColor2, "#001639");
  const brandPlain = String(formData.adaptiveBrandName ?? "");
  const resolveBrand = (t) =>
    String(t ?? "")
      .replace(/\[\[BRAND_NAME\]\]/g, brandPlain)
      .replace(/\$\{brandName\}/g, brandPlain);
  const persona = getAdaptivePersona(formData);
  const story = getMergedAdaptiveStory(formData);
  const subIndustryValue = (formData && formData.adaptiveWebSubIndustry) || "retailBanking";
  const { ind: bundleInd, useCase: bundleUseCase } = getAdaptiveUseCaseBundle(formData);
  const libPack = getResolvedHeroAssetPack(bundleInd || subIndustryValue, bundleUseCase);
  const pickUrl = (formVal, libVal, fallback) => {
    const t = (formVal != null ? String(formVal) : "").trim();
    if (t) return t;
    const l = libVal != null ? String(libVal).trim() : "";
    if (l) return l;
    return fallback;
  };
  const coldHeroUrl = pickUrl(
    formData.adaptiveColdHeroUrl,
    libPack.coldHero,
    DEFAULT_ADAPTIVE_COLD_HERO_IMAGE
  );
  const warmHeroUrl = pickUrl(
    formData.adaptiveHeroImageUrl,
    libPack.warmHero,
    DEFAULT_ADAPTIVE_HERO_IMAGE
  );
  const heroStateEl = document.getElementById("adaptiveHeroState");
  const adaptiveHeroPreviewMode = String((heroStateEl && heroStateEl.value) || "warm")
    .trim()
    .toLowerCase();
  const heroUrl = adaptiveHeroPreviewMode === "cold" ? coldHeroUrl : warmHeroUrl;
  const categoryHeroUrl = String(story.categoryPage?.heroBgImage || "").trim() || coldHeroUrl;
  const navLogoUrl = (formData.adaptiveNavLogoUrl || "").trim() || DEFAULT_ADAPTIVE_NAV_LOGO;
  const insightImg1 = pickUrl(
    formData.adaptiveInsightImg1,
    libPack.insight1,
    DEFAULT_ADAPTIVE_INSIGHT_IMG_1
  );
  const insightImg2 = pickUrl(
    formData.adaptiveInsightImg2,
    libPack.insight2,
    DEFAULT_ADAPTIVE_INSIGHT_IMG_2
  );
  const insightImg3 = pickUrl(
    formData.adaptiveInsightImg3,
    libPack.insight3,
    DEFAULT_ADAPTIVE_INSIGHT_IMG_3
  );
  const mockProfile = {
    firstName: persona.firstName,
    lastName: persona.lastName,
    email: persona.email,
    phone: persona.phone,
    company: persona.company,
    zipCode: persona.zipCode,
  };
  const userIntentResolved = resolveBrand(
    interpolateAdaptivePersona(story.userIntentString || "", persona)
  );
  const agentOpen = resolveBrand(
    interpolateAdaptivePersona(story.agentChatMessage || "", persona)
  );
  const agentAdaptive = resolveBrand(
    interpolateAdaptivePersona(story.agentAdaptiveResponse || "", persona)
  );
  const fill = (text) =>
    escapeHtmlForAdaptive(interpolateAdaptivePersona(resolveBrand(text), persona));
  const categoryPageHtml = buildCategoryPageHtml(story, persona);
  const industryLabels = {
    retailBanking: "Personal Banking",
    commercialBanking: "Commercial Banking",
    wealthManagement: "Wealth Management",
    assetManagement: "Asset Management",
    insurance: "Insurance",
  };
  const subIndustryLabel = industryLabels[subIndustryValue] || "Personal Banking";
  let out = html;
  out = out.replace(/\[\[BRAND_INITIALS\]\]/g, escapeHtmlForAdaptive(formData.adaptiveBrandInitials));
  out = out.replace(/\[\[PRIMARY_COLOR\]\]/g, primary);
  out = out.replace(/\[\[ACCENT_COLOR\]\]/g, accent);
  out = out.replace(/\[\[HERO_GRADIENT_COLOR\]\]/g, heroGradientColor);
  out = out.replace(/\[\[HERO_GRADIENT_COLOR_2\]\]/g, heroGradientColor2);
  out = out.replace(/\[\[VANILLA_HERO_TITLE\]\]/g, fill(story.vanillaHeroTitle || ""));
  out = out.replace(/\[\[VANILLA_HERO_SUBTEXT\]\]/g, fill(story.vanillaHeroSubtext || ""));
  out = out.replace(/\[\[INTENT_TRIGGER_TEXT\]\]/g, fill(story.intentTriggerText));
  out = out.replace(/\[\[CATEGORY_PAGE_HTML\]\]/g, categoryPageHtml);
  out = out.replace(/\[\[SUBPAGE_STRUCTURED_HTML\]\]/g, categoryPageHtml);
  out = out.replace(/\[\[CHAT_WIDGET_TITLE\]\]/g, fill(story.chatWidgetTitle));
  out = out.replace(/\[\[ADAPTIVE_OVERLAY_TITLE\]\]/g, fill(story.adaptiveOverlayTitle));
  out = out.replace(/\[\[ADAPTIVE_OVERLAY_SUBTITLE\]\]/g, fill(story.adaptiveOverlaySubtitle));
  out = out.replace(/\[\[ADAPTIVE_FOOTER_NOTE\]\]/g, fill(story.adaptiveFooterNote));
  out = out.replace(/\[\[LANDING_PAGE_TITLE\]\]/g, fill(story.landingPageTitle));
  out = out.replace(/\[\[LANDING_PAGE_SUBTITLE\]\]/g, fill(story.landingPageSubtitle || ""));
  out = out.replace(/\[\[ADAPTIVE_CARDS_GRID_HTML\]\]/g, buildAdaptiveCardsGridHtml(story.cards, persona));
  out = out.replace(/\[\[MOCK_PROFILE_JSON\]\]/g, JSON.stringify(mockProfile));
  out = out.replace(/\[\[AGENT_GREETING_JSON\]\]/g, JSON.stringify(agentOpen));
  out = out.replace(/\[\[AGENT_FOLLOWUP_JSON\]\]/g, JSON.stringify(agentAdaptive));
  out = out.replace(/\[\[USER_INTENT_JSON\]\]/g, JSON.stringify(userIntentResolved));
  out = out.replace(/\[\[ADAPTIVE_HERO_IMAGE_URL\]\]/g, escapeHtmlAttributeValue(heroUrl));
  out = out.replace(/\[\[COLD_HERO_IMAGE_URL\]\]/g, escapeHtmlAttributeValue(coldHeroUrl));
  out = out.replace(/\[\[INSIGHT_IMG_1\]\]/g, escapeHtmlAttributeValue(insightImg1));
  out = out.replace(/\[\[INSIGHT_IMG_2\]\]/g, escapeHtmlAttributeValue(insightImg2));
  out = out.replace(/\[\[INSIGHT_IMG_3\]\]/g, escapeHtmlAttributeValue(insightImg3));
  out = out.replace(/\[\[WARM_INSIGHT_1_IMG\]\]/g, escapeHtmlAttributeValue(String(story.warmInsight1Img || "").trim()));
  out = out.replace(/\[\[WARM_INSIGHT_2_IMG\]\]/g, escapeHtmlAttributeValue(String(story.warmInsight2Img || "").trim()));
  out = out.replace(/\[\[WARM_INSIGHT_3_IMG\]\]/g, escapeHtmlAttributeValue(String(story.warmInsight3Img || "").trim()));
  out = out.replace(/\[\[WARM_INSIGHT_1_TITLE\]\]/g, fill(story.warmInsight1Title || ""));
  out = out.replace(/\[\[WARM_INSIGHT_2_TITLE\]\]/g, fill(story.warmInsight2Title || ""));
  out = out.replace(/\[\[WARM_INSIGHT_3_TITLE\]\]/g, fill(story.warmInsight3Title || ""));
  out = out.replace(/\[\[COLD_HERO_EYEBROW\]\]/g, fill(story.coldHeroEyebrow || ""));
  out = out.replace(/\[\[COLD_HERO_HEADING\]\]/g, fill(story.coldHeroHeading || ""));
  out = out.replace(/\[\[COLD_HERO_PARAGRAPH_1\]\]/g, fill(story.coldHeroParagraph1 || ""));
  out = out.replace(/\[\[COLD_HERO_PARAGRAPH_2\]\]/g, fill(story.coldHeroParagraph2 || ""));
  out = out.replace(/\[\[HOME_INSIGHTS_HEADING\]\]/g, fill(story.homeInsightsHeading || "Market Insights"));
  out = out.replace(/\[\[HOME_INSIGHTS_SUBTITLE\]\]/g, fill(story.homeInsightsSubtitle || ""));
  out = out.replace(/\[\[HOME_INSIGHT_1_EYEBROW\]\]/g, fill(story.homeInsight1Eyebrow || ""));
  out = out.replace(/\[\[HOME_INSIGHT_1_TITLE\]\]/g, fill(story.homeInsight1Title || ""));
  out = out.replace(/\[\[HOME_INSIGHT_1_BODY\]\]/g, fill(story.homeInsight1Body || ""));
  out = out.replace(/\[\[HOME_INSIGHT_2_EYEBROW\]\]/g, fill(story.homeInsight2Eyebrow || ""));
  out = out.replace(/\[\[HOME_INSIGHT_2_TITLE\]\]/g, fill(story.homeInsight2Title || ""));
  out = out.replace(/\[\[HOME_INSIGHT_2_BODY\]\]/g, fill(story.homeInsight2Body || ""));
  out = out.replace(/\[\[HOME_INSIGHT_3_EYEBROW\]\]/g, fill(story.homeInsight3Eyebrow || ""));
  out = out.replace(/\[\[HOME_INSIGHT_3_TITLE\]\]/g, fill(story.homeInsight3Title || ""));
  out = out.replace(/\[\[HOME_INSIGHT_3_BODY\]\]/g, fill(story.homeInsight3Body || ""));
  out = out.replace(/\[\[WARM_INSIGHT_1_EYEBROW\]\]/g, fill(story.warmInsight1Eyebrow || ""));
  out = out.replace(/\[\[WARM_INSIGHT_1_BODY\]\]/g, fill(story.warmInsight1Body || ""));
  out = out.replace(/\[\[WARM_INSIGHT_2_EYEBROW\]\]/g, fill(story.warmInsight2Eyebrow || ""));
  out = out.replace(/\[\[WARM_INSIGHT_2_BODY\]\]/g, fill(story.warmInsight2Body || ""));
  out = out.replace(/\[\[WARM_INSIGHT_3_EYEBROW\]\]/g, fill(story.warmInsight3Eyebrow || ""));
  out = out.replace(/\[\[WARM_INSIGHT_3_BODY\]\]/g, fill(story.warmInsight3Body || ""));
  out = out.replace(/\[\[ADAPTIVE_SUBPAGE_IMAGE_URL\]\]/g, escapeHtmlAttributeValue(categoryHeroUrl));
  out = out.replace(/\[\[ADAPTIVE_NAV_LOGO_URL\]\]/g, escapeHtmlAttributeValue(navLogoUrl));
  const iconSrc = getAdaptiveWebAgentIconSrc();
  out = out.replace(/\[\[AGENTFORCE_ICON_SRC\]\]/g, escapeHtmlAttributeValue(iconSrc));
  out = out.replace(/\[\[SUB_INDUSTRY_LABEL\]\]/g, escapeHtmlForAdaptive(subIndustryLabel));
  // Editable top-nav labels. getFormData() does not carry these, so read the
  // live input (falling back to formData, then the original banking default),
  // matching the g() pattern used for the rest of the adaptive story.
  const NAV_DEFAULTS = ["Personal", "Corporate", "Banking", "Borrowing", "Investing"];
  NAV_DEFAULTS.forEach((def, i) => {
    const n = i + 1;
    const fromForm = formData && formData[`navLabel${n}`];
    const fromDom = document.getElementById(`navLabel${n}`)?.value;
    const val =
      (fromForm != null && String(fromForm).trim()) ? String(fromForm).trim()
      : (fromDom != null && String(fromDom).trim()) ? String(fromDom).trim()
      : def;
    out = out.replace(new RegExp(`\\[\\[NAV_LABEL_${n}\\]\\]`, "g"), escapeHtmlForAdaptive(val));
  });
  out = out.replace(/\[\[CUSTOMER_FIRST_NAME\]\]/g, escapeHtmlForAdaptive(persona.firstName));
  out = out.replace(/\[\[BRAND_NAME\]\]/g, escapeHtmlForAdaptive(brandPlain));
  return out;
}

/* ===== required load-time invocation (manifest line 5812) ===== */
applyAdaptiveMatrixOverrides();
