//
// App.js – Aplikační logika pro PWA Silový Trénink
// S podporou dynamických tréninkových dnů (A, B, C, D...), progresivního přetížení a jednotlivých sérií
//

// Registrace Service Workeru pro offline režim
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js').catch((err) => {
      console.log('[ServiceWorker] Registrace selhala:', err);
    });
  });
}

// Výchozí definice tréninkových dnů
const DEFAULT_DAYS = [
  {
    id: "workout_a",
    title: "Trénink A",
    focus: "Dřepy / Bench Press / Přítahy",
    scheduleDescription: "Pondělí, Pátek",
    scheduledWeekdays: [1, 5] // 1: Po, 5: Pá
  },
  {
    id: "workout_b",
    title: "Trénink B",
    focus: "Mrtvý tah / Tlaky nad hlavu / Shyby",
    scheduleDescription: "Středa",
    scheduledWeekdays: [3] // 3: St
  }
];

// Výchozí tréninkový split (Trénink A a B) s podporou různých vah pro jednotlivé série
const DEFAULT_WORKOUTS = {
  workout_a: [
    {
      id: "a1",
      exerciseId: "barbell_back_squat",
      name: "Dřep s velkou činkou (Barbell Squat)",
      category: "Nohy",
      weightKg: 80.0,
      targetSets: 3,
      targetReps: 5,
      progressionIncrementKg: 2.5,
      setsData: [
        { setNumber: 1, weightKg: 80.0, reps: 5, completed: false },
        { setNumber: 2, weightKg: 80.0, reps: 5, completed: false },
        { setNumber: 3, weightKg: 80.0, reps: 5, completed: false }
      ],
      notes: "Hloubka pod paralelní úroveň, pauza dole 1s"
    },
    {
      id: "a2",
      exerciseId: "barbell_bench_press",
      name: "Bench Press (Tlak na lavičce)",
      category: "Hrudník",
      weightKg: 12.5,
      targetSets: 3,
      targetReps: 12,
      progressionIncrementKg: 2.5,
      setsData: [
        { setNumber: 1, weightKg: 12.5, reps: 12, completed: false },
        { setNumber: 2, weightKg: 15.0, reps: 12, completed: false },
        { setNumber: 3, weightKg: 17.5, reps: 12, completed: false }
      ],
      notes: "Zatažené lopatky, stopka na hrudníku"
    },
    {
      id: "a3",
      exerciseId: "barbell_bent_over_row",
      name: "Přítahy v předklonu (Barbell Row)",
      category: "Záda",
      weightKg: 55.0,
      targetSets: 3,
      targetReps: 8,
      progressionIncrementKg: 2.5,
      setsData: [
        { setNumber: 1, weightKg: 55.0, reps: 8, completed: false },
        { setNumber: 2, weightKg: 55.0, reps: 8, completed: false },
        { setNumber: 3, weightKg: 55.0, reps: 8, completed: false }
      ],
      notes: "Pevný trup v úhlu 45 stupňů"
    },
    {
      id: "a4",
      exerciseId: "dips_chest_triceps",
      name: "Dipy na bradlech (Parallel Bar Dips)",
      category: "Hrudník & Paže",
      weightKg: 0.0,
      targetSets: 3,
      targetReps: 10,
      progressionIncrementKg: 1.25,
      setsData: [
        { setNumber: 1, weightKg: 0.0, reps: 10, completed: false },
        { setNumber: 2, weightKg: 0.0, reps: 10, completed: false },
        { setNumber: 3, weightKg: 0.0, reps: 10, completed: false }
      ],
      notes: "Vlastní váha těla"
    }
  ],
  workout_b: [
    {
      id: "b1",
      exerciseId: "barbell_deadlift",
      name: "Mrtvý tah (Barbell Deadlift)",
      category: "Záda & Nohy",
      weightKg: 100.0,
      targetSets: 3,
      targetReps: 5,
      progressionIncrementKg: 5.0,
      setsData: [
        { setNumber: 1, weightKg: 100.0, reps: 5, completed: false },
        { setNumber: 2, weightKg: 100.0, reps: 5, completed: false },
        { setNumber: 3, weightKg: 100.0, reps: 5, completed: false }
      ],
      notes: "Rovná záda, osa těsně u nohou"
    },
    {
      id: "b2",
      exerciseId: "overhead_press_barbell",
      name: "Tlak nad hlavu (Overhead Press / OHP)",
      category: "Ramena",
      weightKg: 42.5,
      targetSets: 3,
      targetReps: 5,
      progressionIncrementKg: 2.5,
      setsData: [
        { setNumber: 1, weightKg: 42.5, reps: 5, completed: false },
        { setNumber: 2, weightKg: 42.5, reps: 5, completed: false },
        { setNumber: 3, weightKg: 42.5, reps: 5, completed: false }
      ],
      notes: "Zpevněné břicho a hýždě"
    },
    {
      id: "b3",
      exerciseId: "pull_ups_bodyweight",
      name: "Shyby na hrazdě (Pull-ups)",
      category: "Záda",
      weightKg: 0.0,
      targetSets: 3,
      targetReps: 8,
      progressionIncrementKg: 1.25,
      setsData: [
        { setNumber: 1, weightKg: 0.0, reps: 8, completed: false },
        { setNumber: 2, weightKg: 0.0, reps: 8, completed: false },
        { setNumber: 3, weightKg: 0.0, reps: 8, completed: false }
      ],
      notes: "Plný rozsah pohybu"
    },
    {
      id: "b4",
      exerciseId: "barbell_biceps_curl",
      name: "Bicepsový zdvih s velkou činkou",
      category: "Paže",
      weightKg: 30.0,
      targetSets: 3,
      targetReps: 10,
      progressionIncrementKg: 2.5,
      setsData: [
        { setNumber: 1, weightKg: 30.0, reps: 10, completed: false },
        { setNumber: 2, weightKg: 30.0, reps: 10, completed: false },
        { setNumber: 3, weightKg: 30.0, reps: 10, completed: false }
      ],
      notes: "Bez švihu tělem"
    }
  ]
};

// Stav aplikace
const AppState = {
  currentTab: 'workout_a',
  days: [],
  workouts: {},
  databaseExercises: [],
  selectedCategory: 'Všechny',
  expandedItemIds: new Set()
};

// Zajištění integrity a existence pole sérií pro každý cvik
function ensureSetsData(item) {
  const count = parseInt(item.targetSets, 10) || 3;
  const defaultWeight = parseFloat(item.weightKg) || 0;
  const defaultReps = parseInt(item.targetReps, 10) || 10;
  if (!item.progressionIncrementKg) {
    item.progressionIncrementKg = 2.5;
  }

  if (!item.setsData || !Array.isArray(item.setsData)) {
    item.setsData = [];
  }

  while (item.setsData.length < count) {
    const setIdx = item.setsData.length + 1;
    const prevWeight = item.setsData.length > 0 ? item.setsData[item.setsData.length - 1].weightKg : defaultWeight;
    item.setsData.push({
      setNumber: setIdx,
      weightKg: prevWeight,
      reps: defaultReps,
      completed: false
    });
  }

  if (item.setsData.length > count) {
    item.setsData = item.setsData.slice(0, count);
  }

  item.setsData.forEach((s, idx) => {
    s.setNumber = idx + 1;
    if (s.weightKg === undefined || isNaN(s.weightKg)) s.weightKg = defaultWeight;
    if (s.reps === undefined || isNaN(s.reps)) s.reps = defaultReps;
    if (s.completed === undefined) s.completed = false;
  });
}

// Načtení dat z localStorage
function loadWorkoutsFromStorage() {
  try {
    const raw = localStorage.getItem('silovy_trenink_data');
    if (raw) {
      const parsed = JSON.parse(raw);
      AppState.days = parsed.days && parsed.days.length > 0 ? parsed.days : JSON.parse(JSON.stringify(DEFAULT_DAYS));
      AppState.workouts = parsed.workouts || (parsed.workout_a ? { workout_a: parsed.workout_a, workout_b: parsed.workout_b } : JSON.parse(JSON.stringify(DEFAULT_WORKOUTS)));
    } else {
      AppState.days = JSON.parse(JSON.stringify(DEFAULT_DAYS));
      AppState.workouts = JSON.parse(JSON.stringify(DEFAULT_WORKOUTS));
      saveWorkoutsToStorage();
    }
  } catch (err) {
    console.error('Chyba při načítání z localStorage:', err);
    AppState.days = JSON.parse(JSON.stringify(DEFAULT_DAYS));
    AppState.workouts = JSON.parse(JSON.stringify(DEFAULT_WORKOUTS));
  }

  // Zkontrolujeme platnost aktivní záložky
  if (!AppState.days.find(d => d.id === AppState.currentTab)) {
    AppState.currentTab = AppState.days[0] ? AppState.days[0].id : 'workout_a';
  }

  // Zajistíme setsData pro všechny dny a cviky
  AppState.days.forEach(day => {
    if (!AppState.workouts[day.id]) {
      AppState.workouts[day.id] = [];
    }
    AppState.workouts[day.id].forEach(item => ensureSetsData(item));
  });
}

// Uložení dat do localStorage
function saveWorkoutsToStorage() {
  try {
    const payload = {
      days: AppState.days,
      workouts: AppState.workouts
    };
    localStorage.setItem('silovy_trenink_data', JSON.stringify(payload));
  } catch (err) {
    console.error('Chyba při ukládání do localStorage:', err);
  }
}

// Načtení databáze cviků z exercises.json s do-catch / try-catch
async function loadExerciseDatabase() {
  try {
    const res = await fetch('./exercises.json');
    if (!res.ok) throw new Error(`HTTP error ${res.status}`);
    const data = await res.json();
    AppState.databaseExercises = data;
    renderCategoriesBar();
    renderDatabaseList();
  } catch (err) {
    console.warn('Nepodařilo se načíst exercises.json, použita vestavěná data:', err);
  }
}

// Dynamické vykreslení spodního TabBaru se všemi tréninkovými dny (A, B, C, D...)
function renderTabBar() {
  const container = document.getElementById('main-tabbar');
  if (!container) return;

  container.innerHTML = AppState.days.map((day, idx) => {
    // Vytáhneme zkrácený identifikátor (např. A, B, C nebo první písmeno)
    let iconLabel = day.title.replace(/trénink\s*/i, '').trim()[0] || `${idx + 1}`;
    iconLabel = iconLabel.toUpperCase();
    const isActive = AppState.currentTab === day.id;

    return `
      <button class="tab-item ${isActive ? 'active' : ''}" onclick="switchWorkoutDay('${day.id}')">
        <div class="tab-icon">${escapeHtml(iconLabel)}</div>
        <span class="tab-label">${escapeHtml(day.title)}</span>
      </button>
    `;
  }).join('');
}

// Přepnutí aktivního tréninkového dne
function switchWorkoutDay(dayId) {
  AppState.currentTab = dayId;
  renderTabBar();
  renderExerciseList();
  updateScheduleBanner();
}

// Vyhodnocení dne v týdnu pro indikaci a stavu odcvičených cviků
function updateScheduleBanner() {
  const currentDayMeta = AppState.days.find(d => d.id === AppState.currentTab) || {
    id: AppState.currentTab,
    title: 'Trénink',
    focus: 'Vlastní zaměření',
    scheduleDescription: 'Dle potřeby',
    scheduledWeekdays: []
  };

  const titleEl = document.getElementById('banner-workout-title');
  const focusEl = document.getElementById('banner-workout-focus');
  const badgeEl = document.getElementById('banner-schedule-badge');
  const countEl = document.getElementById('banner-exercise-count');
  const pctEl = document.getElementById('banner-progress-percent');
  const fillEl = document.getElementById('banner-progress-fill');

  const items = AppState.workouts[AppState.currentTab] || [];
  const total = items.length;
  const completedCount = items.filter(i => {
    ensureSetsData(i);
    return i.setsData.length > 0 && i.setsData.every(s => s.completed);
  }).length;

  const pct = total > 0 ? Math.round((completedCount / total) * 100) : 0;

  if (titleEl) titleEl.textContent = currentDayMeta.title;
  if (focusEl) focusEl.textContent = currentDayMeta.focus || 'Silový trénink';
  if (countEl) countEl.textContent = `Odcvičeno: ${completedCount} z ${total} cviků`;
  if (pctEl) pctEl.textContent = `${pct} %`;
  if (fillEl) fillEl.style.width = `${pct}%`;

  const currentWeekday = new Date().getDay(); // 0 = Ne, 1 = Po, 2 = Út, 3 = St, 4 = Čt, 5 = Pá, 6 = So
  const isToday = Array.isArray(currentDayMeta.scheduledWeekdays) && currentDayMeta.scheduledWeekdays.includes(currentWeekday);

  if (badgeEl) {
    if (isToday) {
      badgeEl.textContent = 'Dnes na plánu';
      badgeEl.className = 'badge-schedule today';
    } else if (currentDayMeta.scheduleDescription && currentDayMeta.scheduleDescription !== "Dle potřeby") {
      badgeEl.textContent = `Plán: ${currentDayMeta.scheduleDescription}`;
      badgeEl.className = 'badge-schedule';
    } else {
      badgeEl.textContent = 'Plán: Dle potřeby';
      badgeEl.className = 'badge-schedule';
    }
  }
}

// Získání formátovaného přehledu cviku v hlavičce
function getItemSummaryText(item) {
  ensureSetsData(item);
  const sets = item.setsData;
  if (!sets || sets.length === 0) return `${item.targetSets} sérií`;

  const weights = sets.map(s => Number(s.weightKg).toFixed(1).replace('.0', ''));
  const allSameWeight = weights.every(w => w === weights[0]);
  const reps = sets[0].reps;
  const allSameReps = sets.every(s => s.reps === reps);

  if (allSameWeight) {
    return `${sets.length} série × ${sets[0].reps} reps @ ${weights[0]} kg`;
  } else {
    const weightsStr = weights.join('; ') + ' kg';
    if (allSameReps) {
      return `${sets.length} série (${weightsStr}) × ${reps} reps`;
    } else {
      return `${sets.length} série (${weightsStr})`;
    }
  }
}

// Vykreslení seznamu cviků s dynamickým číslováním (1, 2, 3...)
function renderExerciseList() {
  const container = document.getElementById('exercise-list-container');
  const items = AppState.workouts[AppState.currentTab] || [];
  const activeDay = AppState.days.find(d => d.id === AppState.currentTab);
  const dayTitle = activeDay ? activeDay.title : 'tomto tréninku';

  if (items.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 40px 20px; color: var(--text-secondary);">
        <h3 style="margin-bottom: 8px; color: var(--text-primary);">Žádné cviky v ${escapeHtml(dayTitle)}</h3>
        <p style="font-size: 14px; margin-bottom: 20px;">Klikněte na tlačítko níže pro přidání cviku z databáze nebo vytvoření vlastního.</p>
        <button class="btn-add-exercise-card" onclick="openAddExerciseModal()">+ Přidat první cvik</button>
      </div>
    `;
    updateScheduleBanner();
    return;
  }

  let html = '';

  items.forEach((item, index) => {
    ensureSetsData(item);
    const itemNumber = index + 1;
    const isExpanded = AppState.expandedItemIds.has(item.id);
    const summaryText = getItemSummaryText(item);
    
    // Vyhodnocení stavu splnění
    const allCompleted = item.setsData.length > 0 && item.setsData.every(s => s.completed);
    const completedSetsCount = item.setsData.filter(s => s.completed).length;
    const cardStatusClass = allCompleted ? 'completed' : (completedSetsCount > 0 ? 'in-progress' : '');

    html += `
      <div class="exercise-card ${cardStatusClass} ${isExpanded ? 'expanded' : ''}" id="card-${item.id}">
        <!-- Textová hlavička (Vždy viditelná) -->
        <button class="exercise-header-btn" onclick="toggleExpand('${item.id}')">
          <div class="exercise-number">
            ${allCompleted ? '✓' : itemNumber}
          </div>
          <div class="exercise-info">
            <div class="exercise-top-line">
              <span class="exercise-name">${escapeHtml(item.name)}</span>
              
              ${allCompleted 
                ? '<span class="status-badge done">✓ Hotovo</span>' 
                : (completedSetsCount > 0 
                    ? `<span class="status-badge in-progress">${completedSetsCount}/${item.setsData.length}</span>` 
                    : `<span class="expand-tag">${isExpanded ? '▲ Skrýt' : '▼ Upravit'}</span>`
                  )
              }
            </div>
            
            <div class="exercise-meta-line">
              <span class="category-tag">${escapeHtml(item.category || 'Cvik')}</span>
              <span class="summary-text">${summaryText}</span>
            </div>
          </div>
        </button>

        <!-- Rozbalovací detail s poli pro váhy jednotlivých sérií a progresivní přetížení -->
        <div class="exercise-detail-panel">
          <!-- Rychlá akce pro celý cvik -->
          <div style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 4px;">
            <div class="panel-title">Nastavení parametrů a sérií:</div>
            <button 
              class="btn-set-check ${allCompleted ? 'done' : ''}" 
              onclick="toggleAllSetsInExercise('${item.id}')"
              style="padding: 4px 10px; font-size: 11px;"
            >
              ${allCompleted ? '✓ Vše splněno' : 'Označit celý cvik'}
            </button>
          </div>

          <!-- Globální počet sérií a krok progresu -->
          <div class="row-dual-inputs">
            <div class="input-control-row">
              <div class="input-label-row">
                <span>Počet sérií</span>
                <span class="unit-badge">sérií</span>
              </div>
              <div class="stepper-row">
                <button class="stepper-btn" onclick="adjustGlobalSets('${item.id}', -1)" aria-label="Snížit série">−</button>
                <div class="stepper-field-container">
                  <input 
                    type="number" 
                    class="stepper-field" 
                    value="${item.targetSets || 3}" 
                    onchange="updateGlobalSetsDirect('${item.id}', this.value)"
                  />
                </div>
                <button class="stepper-btn" onclick="adjustGlobalSets('${item.id}', 1)" aria-label="Zvýšit série">+</button>
              </div>
            </div>

            <div class="input-control-row">
              <div class="input-label-row">
                <span>Přírůstek na příště</span>
                <span class="unit-badge">+kg</span>
              </div>
              <div class="stepper-row">
                <button class="stepper-btn" onclick="adjustProgressionIncrement('${item.id}', -1.25)" aria-label="Snížit přírůstek">−</button>
                <div class="stepper-field-container">
                  <input 
                    type="number" 
                    step="0.25"
                    class="stepper-field" 
                    value="${item.progressionIncrementKg || 2.5}" 
                    onchange="updateProgressionIncrementDirect('${item.id}', this.value)"
                  />
                  <span class="stepper-unit">kg</span>
                </div>
                <button class="stepper-btn" onclick="adjustProgressionIncrement('${item.id}', 1.25)" aria-label="Zvýšit přírůstek">+</button>
              </div>
            </div>
          </div>

          <!-- Rozpis jednotlivých sérií s vlastní váhou a opakováním -->
          <div style="display: flex; flex-direction: column; gap: 8px;">
            <div class="panel-title" style="margin-top: 4px;">Jednotlivé série (Váha & Opakování):</div>
            ${generateSetsCardsHtml(item)}
          </div>

          <!-- Poznámky k technice -->
          <div class="input-control-row">
            <span class="input-label-row">Poznámky k technice / pauzy:</span>
            <input 
              type="text" 
              class="notes-input" 
              placeholder="Např. pauza 90s, stopka dole..." 
              value="${escapeHtml(item.notes || '')}"
              onchange="updateNotesDirect('${item.id}', this.value)"
            />
          </div>

          <!-- Akční lišta detailu -->
          <div class="detail-actions-row">
            <button class="btn-delete" onclick="deleteExercise('${item.id}')">Odstranit cvik</button>
            <button class="btn-done" onclick="toggleExpand('${item.id}')">Hotovo</button>
          </div>
        </div>
      </div>
    `;
  });

  // Tlačítko pro přidání dalšího cviku
  html += `
    <button class="btn-add-exercise-card" onclick="openAddExerciseModal()">
      + Přidat další cvik
    </button>
  `;

  // Globální tlačítko pro uzavření tréninku a navýšení vah na příště
  const anyCompleted = items.some(i => i.setsData && i.setsData.some(s => s.completed));
  if (anyCompleted) {
    html += `
      <button class="btn-finish-workout" onclick="finishWorkoutAndProgress()">
        🏆 Dokončit dnešní trénink & Navýšit váhy na příště
      </button>
    `;
  }

  container.innerHTML = html;
  updateScheduleBanner();
}

// Posun cviku nahoru v pořadí (při obsazených strojích)
function moveExerciseUp(itemId) {
  const list = AppState.workouts[AppState.currentTab];
  const idx = list.findIndex(i => i.id === itemId);
  if (idx > 0) {
    const temp = list[idx];
    list[idx] = list[idx - 1];
    list[idx - 1] = temp;
    saveWorkoutsToStorage();
    renderExerciseList();
    showToast(`Cvik "${temp.name}" posunut nahoru`);
  }
}

// Posun cviku dolů v pořadí
function moveExerciseDown(itemId) {
  const list = AppState.workouts[AppState.currentTab];
  const idx = list.findIndex(i => i.id === itemId);
  if (idx > -1 && idx < list.length - 1) {
    const temp = list[idx];
    list[idx] = list[idx + 1];
    list[idx + 1] = temp;
    saveWorkoutsToStorage();
    renderExerciseList();
    showToast(`Cvik "${temp.name}" posunut dolů`);
  }
}

// Rychlé označení všech sérií v cviku najednou
function toggleAllSetsInExercise(itemId) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  ensureSetsData(item);
  const allDone = item.setsData.every(s => s.completed);
  item.setsData.forEach(s => s.completed = !allDone);
  saveWorkoutsToStorage();
  renderExerciseList();
  showToast(allDone ? `Označení cviku "${item.name}" zrušeno` : `Cvik "${item.name}" označen jako hotový! ✓`);
}

// Vygenerování karet jednotlivých sérií a banneru progresivního přetížení
function generateSetsCardsHtml(item) {
  ensureSetsData(item);
  const inc = parseFloat(item.progressionIncrementKg) || 2.5;
  const allCompleted = item.setsData.length > 0 && item.setsData.every(s => s.completed);

  let html = '';

  // 1. Banner progresivního přetížení při splnění všech sérií
  if (allCompleted) {
    const nextPreview = item.setsData.map(s => {
      const nextW = (Math.round((s.weightKg + inc) * 10) / 10).toFixed(1).replace('.0', '');
      return `${nextW} kg`;
    }).join('; ');

    html += `
      <div class="progression-banner">
        <div class="progression-title">
          <span>🚀 Všechny série splněny!</span>
        </div>
        <div class="progression-desc">
          Odcvičili jste všechny série cviku. Na příští týden / trénink bude nachystáno navýšení o <strong>+${inc} kg</strong>:
          <div class="progression-preview">
            Nové váhy na příště: <strong>${nextPreview}</strong>
          </div>
        </div>
        <button class="btn-apply-progression" onclick="applyProgression('${item.id}')">
          ⚡ Aplikovat novou váhu na příště (+${inc} kg)
        </button>
      </div>
    `;
  }

  // 2. Karta pro každou jednotlivou sérii s vlastní váhou a opakováním
  item.setsData.forEach(set => {
    const weightFormatted = Number(set.weightKg).toFixed(1).replace('.0', '');
    html += `
      <div class="set-row-card ${set.completed ? 'completed' : ''}">
        <div class="set-row-top">
          <span class="set-badge">Série ${set.setNumber}</span>
          <button 
            class="btn-set-check ${set.completed ? 'done' : ''}" 
            onclick="toggleSetCheck('${item.id}', ${set.setNumber})"
          >
            ${set.completed ? '✓ Hotovo' : 'Označit splněno'}
          </button>
        </div>

        <div class="set-row-controls">
          <!-- Váha pro tuto sérii -->
          <div class="set-micro-control">
            <span class="set-micro-label">Váha série (kg):</span>
            <div class="micro-stepper">
              <button class="micro-btn" onclick="adjustSetWeight('${item.id}', ${set.setNumber}, -2.5)" aria-label="Snížit">−</button>
              <input 
                type="number" 
                step="0.5" 
                class="micro-input" 
                value="${weightFormatted}" 
                onchange="updateSetWeightDirect('${item.id}', ${set.setNumber}, this.value)"
              />
              <span class="micro-unit">kg</span>
              <button class="micro-btn" onclick="adjustSetWeight('${item.id}', ${set.setNumber}, 2.5)" aria-label="Zvýšit">+</button>
            </div>
          </div>

          <!-- Opakování pro tuto sérii (pod váhou) -->
          <div class="set-micro-control">
            <span class="set-micro-label">Počet opakování:</span>
            <div class="micro-stepper">
              <button class="micro-btn" onclick="adjustSetReps('${item.id}', ${set.setNumber}, -1)" aria-label="Snížit">−</button>
              <input 
                type="number" 
                class="micro-input" 
                value="${set.reps}" 
                onchange="updateSetRepsDirect('${item.id}', ${set.setNumber}, this.value)"
              />
              <span class="micro-unit">reps</span>
              <button class="micro-btn" onclick="adjustSetReps('${item.id}', ${set.setNumber}, 1)" aria-label="Zvýšit">+</button>
            </div>
          </div>
        </div>
      </div>
    `;
  });

  return html;
}

// Přepínání rozbalení / sbalení cviku
function toggleExpand(itemId) {
  if (AppState.expandedItemIds.has(itemId)) {
    AppState.expandedItemIds.delete(itemId);
  } else {
    AppState.expandedItemIds.add(itemId);
  }
  renderExerciseList();
  if (AppState.expandedItemIds.has(itemId)) {
    setTimeout(() => {
      const el = document.getElementById(`card-${itemId}`);
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      }
    }, 100);
  }
}

// Úprava váhy pro konkrétní sérii
function adjustSetWeight(itemId, setNumber, delta) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  ensureSetsData(item);
  const set = item.setsData.find(s => s.setNumber === setNumber);
  if (!set) return;

  const current = Number(set.weightKg) || 0;
  set.weightKg = Math.max(0, Math.min(500, Math.round((current + delta) * 10) / 10));
  saveWorkoutsToStorage();
  renderExerciseList();
}

function updateSetWeightDirect(itemId, setNumber, val) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  ensureSetsData(item);
  const set = item.setsData.find(s => s.setNumber === setNumber);
  if (!set) return;

  const parsed = parseFloat(val);
  if (!isNaN(parsed)) {
    set.weightKg = Math.max(0, Math.min(500, parsed));
    saveWorkoutsToStorage();
    renderExerciseList();
  }
}

// Úprava opakování pro konkrétní sérii
function adjustSetReps(itemId, setNumber, delta) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  ensureSetsData(item);
  const set = item.setsData.find(s => s.setNumber === setNumber);
  if (!set) return;

  const current = parseInt(set.reps, 10) || 1;
  set.reps = Math.max(1, Math.min(100, current + delta));
  saveWorkoutsToStorage();
  renderExerciseList();
}

function updateSetRepsDirect(itemId, setNumber, val) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  ensureSetsData(item);
  const set = item.setsData.find(s => s.setNumber === setNumber);
  if (!set) return;

  const parsed = parseInt(val, 10);
  if (!isNaN(parsed)) {
    set.reps = Math.max(1, Math.min(100, parsed));
    saveWorkoutsToStorage();
    renderExerciseList();
  }
}

// Přepínání splnění jednotlivé série
function toggleSetCheck(itemId, setNumber) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  ensureSetsData(item);
  const set = item.setsData.find(s => s.setNumber === setNumber);
  if (!set) return;

  set.completed = !set.completed;
  saveWorkoutsToStorage();
  renderExerciseList();

  const allDone = item.setsData.every(s => s.completed);
  if (allDone) {
    showToast(`Všechny série pro "${item.name}" splněny! Připraven progres.`);
  }
}

// Aplikování progresivního přetížení na konkrétní cvik
function applyProgression(itemId) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  ensureSetsData(item);

  const inc = parseFloat(item.progressionIncrementKg) || 2.5;

  item.setsData.forEach(s => {
    s.weightKg = Math.round((s.weightKg + inc) * 10) / 10;
    s.completed = false;
  });

  item.weightKg = item.setsData[0].weightKg;
  saveWorkoutsToStorage();
  renderExerciseList();

  const preview = item.setsData.map(s => `${Number(s.weightKg).toFixed(1).replace('.0', '')} kg`).join(', ');
  showToast(`Váhy navýšeny na příště: ${preview} (+${inc} kg) 💪`);
}

// Globální dokončení tréninku a navýšení vah na příště
function finishWorkoutAndProgress() {
  const items = AppState.workouts[AppState.currentTab] || [];
  let progressedCount = 0;

  items.forEach(item => {
    ensureSetsData(item);
    const allDone = item.setsData.every(s => s.completed);
    const inc = parseFloat(item.progressionIncrementKg) || 2.5;

    if (allDone) {
      item.setsData.forEach(s => {
        s.weightKg = Math.round((s.weightKg + inc) * 10) / 10;
        s.completed = false;
      });
      item.weightKg = item.setsData[0].weightKg;
      progressedCount++;
    } else {
      item.setsData.forEach(s => s.completed = false);
    }
  });

  saveWorkoutsToStorage();
  renderExerciseList();

  if (progressedCount > 0) {
    showToast(`Trénink dokončen! U ${progressedCount} cviků byly navýšeny váhy na příště! 💪🎉`);
  } else {
    showToast(`Trénink byl resetován pro příští týden.`);
  }
}

// Globální počet sérií
function adjustGlobalSets(itemId, delta) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  const current = parseInt(item.targetSets, 10) || 3;
  item.targetSets = Math.max(1, Math.min(20, current + delta));
  ensureSetsData(item);
  saveWorkoutsToStorage();
  renderExerciseList();
}

function updateGlobalSetsDirect(itemId, val) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  const parsed = parseInt(val, 10);
  if (!isNaN(parsed)) {
    item.targetSets = Math.max(1, Math.min(20, parsed));
    ensureSetsData(item);
    saveWorkoutsToStorage();
    renderExerciseList();
  }
}

// Nastavení přírůstku progresu (kg)
function adjustProgressionIncrement(itemId, delta) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  const current = parseFloat(item.progressionIncrementKg) || 2.5;
  item.progressionIncrementKg = Math.max(0.5, Math.min(20, Math.round((current + delta) * 100) / 100));
  saveWorkoutsToStorage();
  renderExerciseList();
}

function updateProgressionIncrementDirect(itemId, val) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  const parsed = parseFloat(val);
  if (!isNaN(parsed)) {
    item.progressionIncrementKg = Math.max(0.5, Math.min(20, parsed));
    saveWorkoutsToStorage();
    renderExerciseList();
  }
}

function updateNotesDirect(itemId, val) {
  const items = AppState.workouts[AppState.currentTab];
  const item = items.find(i => i.id === itemId);
  if (!item) return;
  item.notes = val;
  saveWorkoutsToStorage();
}

function deleteExercise(itemId) {
  if (confirm("Opravdu chcete tento cvik odstranit ze seznamu?")) {
    AppState.workouts[AppState.currentTab] = AppState.workouts[AppState.currentTab].filter(i => i.id !== itemId);
    AppState.expandedItemIds.delete(itemId);
    saveWorkoutsToStorage();
    renderExerciseList();
    showToast("Cvik byl odstraněn");
  }
}

// ==========================================
// SPRÁVA TRÉNINKOVÝCH DNŮ (A, B, C, D...)
// ==========================================

function openAddDayModal() {
  const existingCount = AppState.days.length;
  const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const nextLetter = letters[existingCount] || `${existingCount + 1}`;
  
  const titleInput = document.getElementById('new-day-title');
  const focusInput = document.getElementById('new-day-focus');
  const scheduleInput = document.getElementById('new-day-schedule');

  if (titleInput) titleInput.value = `Trénink ${nextLetter}`;
  if (focusInput) focusInput.value = "";
  if (scheduleInput) scheduleInput.value = "";

  const modal = document.getElementById('modal-add-day');
  if (modal) modal.classList.add('open');
}

function closeAddDayModal() {
  const modal = document.getElementById('modal-add-day');
  if (modal) modal.classList.remove('open');
}

function saveNewWorkoutDay() {
  const titleInput = document.getElementById('new-day-title');
  const focusInput = document.getElementById('new-day-focus');
  const scheduleInput = document.getElementById('new-day-schedule');

  const title = (titleInput?.value || "").trim();
  if (!title) {
    alert("Zadejte prosím název tréninkového dne.");
    return;
  }

  const focus = (focusInput?.value || "").trim();
  const schedule = (scheduleInput?.value || "").trim();
  const newId = 'day_' + Date.now();

  const newDay = {
    id: newId,
    title: title,
    focus: focus || "Vlastní zaměření",
    scheduleDescription: schedule || "Dle potřeby",
    scheduledWeekdays: []
  };

  AppState.days.push(newDay);
  AppState.workouts[newId] = [];
  AppState.currentTab = newId;

  saveWorkoutsToStorage();
  closeAddDayModal();
  renderTabBar();
  renderExerciseList();
  updateScheduleBanner();

  showToast(`Tréninkový den "${title}" byl vytvořen!`);
}

function openEditDayModal() {
  const currentDay = AppState.days.find(d => d.id === AppState.currentTab);
  if (!currentDay) return;

  const titleInput = document.getElementById('edit-day-title');
  const focusInput = document.getElementById('edit-day-focus');
  const scheduleInput = document.getElementById('edit-day-schedule');

  if (titleInput) titleInput.value = currentDay.title || "";
  if (focusInput) focusInput.value = currentDay.focus || "";
  if (scheduleInput) scheduleInput.value = currentDay.scheduleDescription || "";

  const modal = document.getElementById('modal-edit-day');
  if (modal) modal.classList.add('open');
}

function closeEditDayModal() {
  const modal = document.getElementById('modal-edit-day');
  if (modal) modal.classList.remove('open');
}

function saveEditedWorkoutDay() {
  const currentDay = AppState.days.find(d => d.id === AppState.currentTab);
  if (!currentDay) return;

  const titleInput = document.getElementById('edit-day-title');
  const focusInput = document.getElementById('edit-day-focus');
  const scheduleInput = document.getElementById('edit-day-schedule');

  const title = (titleInput?.value || "").trim();
  if (!title) {
    alert("Zadejte prosím název tréninkového dne.");
    return;
  }

  currentDay.title = title;
  currentDay.focus = (focusInput?.value || "").trim() || "Vlastní zaměření";
  currentDay.scheduleDescription = (scheduleInput?.value || "").trim() || "Dle potřeby";

  saveWorkoutsToStorage();
  closeEditDayModal();
  renderTabBar();
  renderExerciseList();
  updateScheduleBanner();

  showToast(`Tréninkový den "${title}" byl upraven!`);
}

function deleteCurrentWorkoutDay() {
  if (AppState.days.length <= 1) {
    alert("Nelze smazat jediný zbývající tréninkový den. Aplikace potřebuje alespoň jeden trénink.");
    return;
  }

  const currentDay = AppState.days.find(d => d.id === AppState.currentTab);
  const title = currentDay ? currentDay.title : 'tento trénink';

  if (!confirm(`Opravdu chcete smazat celý "${title}" včetně všech cviků? Tato akce je nevratná.`)) {
    return;
  }

  const dayIdToDelete = AppState.currentTab;
  AppState.days = AppState.days.filter(d => d.id !== dayIdToDelete);
  delete AppState.workouts[dayIdToDelete];

  // Přepneme na první dostupný den
  AppState.currentTab = AppState.days[0].id;

  saveWorkoutsToStorage();
  closeEditDayModal();
  renderTabBar();
  renderExerciseList();
  updateScheduleBanner();

  showToast(`Trénink "${title}" byl smazán.`);
}

// ==========================================
// PŘIDÁVÁNÍ CVIKŮ DO VYBRANÉHO DNE
// ==========================================

function openAddExerciseModal() {
  const currentDay = AppState.days.find(d => d.id === AppState.currentTab);
  const dayTitle = currentDay ? currentDay.title : 'Tréninku';
  document.getElementById('modal-title-text').textContent = `Přidat cvik do ${dayTitle}`;
  document.getElementById('modal-add-exercise').classList.add('open');
  renderDatabaseList();
}

function closeAddExerciseModal() {
  document.getElementById('modal-add-exercise').classList.remove('open');
}

// Vykreslení kategorií
function renderCategoriesBar() {
  const container = document.getElementById('db-categories-bar');
  if (!container) return;
  const cats = ['Všechny', ...new Set(AppState.databaseExercises.map(e => e.category))];
  
  container.innerHTML = cats.map(cat => `
    <button class="cat-pill ${AppState.selectedCategory === cat ? 'active' : ''}" onclick="selectCategory('${cat}')">
      ${cat}
    </button>
  `).join('');
}

function selectCategory(cat) {
  AppState.selectedCategory = cat;
  renderCategoriesBar();
  renderDatabaseList();
}

// Vykreslení cviků z databáze v modálu
function renderDatabaseList() {
  const container = document.getElementById('db-exercises-list');
  const search = (document.getElementById('db-search-input')?.value || '').toLowerCase().trim();
  
  const filtered = AppState.databaseExercises.filter(ex => {
    const matchesCat = AppState.selectedCategory === 'Všechny' || ex.category === AppState.selectedCategory;
    if (!matchesCat) return false;
    if (!search) return true;
    return ex.name.toLowerCase().includes(search) || 
           ex.category.toLowerCase().includes(search) ||
           (ex.primary_muscles && ex.primary_muscles.some(m => m.toLowerCase().includes(search)));
  });

  if (filtered.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 20px; color: var(--text-secondary); font-size: 13px;">
        Nenalezen žádný cvik. Můžete vytvořit vlastní v záložce "Vlastní cvik".
      </div>
    `;
    return;
  }

  container.innerHTML = filtered.map(ex => {
    const muscles = (ex.primary_muscles || []).join(', ') || ex.category;
    return `
      <button class="db-item-btn" onclick="addExerciseFromDatabase('${ex.id}')">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <strong style="font-size: 15px; color: var(--text-primary);">${escapeHtml(ex.name)}</strong>
          <span class="category-tag">${escapeHtml(ex.category)}</span>
        </div>
        <div style="font-size: 12px; color: var(--text-secondary);">Svaly: ${escapeHtml(muscles)}</div>
      </button>
    `;
  }).join('');
}

// Přidání cviku z databáze
function addExerciseFromDatabase(exerciseId) {
  const dbEx = AppState.databaseExercises.find(e => e.id === exerciseId);
  if (!dbEx) return;

  const setsCount = 3;
  const initialWeight = 60.0;
  const initialReps = 10;

  const newItem = {
    id: 'ex_' + Date.now(),
    exerciseId: dbEx.id,
    name: dbEx.name,
    category: dbEx.category,
    weightKg: initialWeight,
    targetSets: setsCount,
    targetReps: initialReps,
    progressionIncrementKg: 2.5,
    setsData: [
      { setNumber: 1, weightKg: initialWeight, reps: initialReps, completed: false },
      { setNumber: 2, weightKg: initialWeight, reps: initialReps, completed: false },
      { setNumber: 3, weightKg: initialWeight, reps: initialReps, completed: false }
    ],
    notes: ""
  };

  AppState.workouts[AppState.currentTab].push(newItem);
  AppState.expandedItemIds.add(newItem.id);
  saveWorkoutsToStorage();
  closeAddExerciseModal();
  renderExerciseList();
  showToast(`Cvik "${dbEx.name}" byl přidán`);

  setTimeout(() => {
    const el = document.getElementById(`card-${newItem.id}`);
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
  }, 100);
}

// Vlastní cvik formulář logika
function adjustCustomWeight(delta) {
  const el = document.getElementById('custom-weight-input');
  const val = parseFloat(el.value) || 0;
  el.value = (Math.max(0, val + delta)).toFixed(1);
}

function adjustCustomSets(delta) {
  const el = document.getElementById('custom-sets-input');
  const val = parseInt(el.value, 10) || 1;
  el.value = Math.max(1, Math.min(20, val + delta));
}

function adjustCustomReps(delta) {
  const el = document.getElementById('custom-reps-input');
  const val = parseInt(el.value, 10) || 1;
  el.value = Math.max(1, Math.min(100, val + delta));
}

function saveCustomExercise() {
  const nameInput = document.getElementById('custom-name-input');
  const catInput = document.getElementById('custom-cat-select');
  const weightInput = document.getElementById('custom-weight-input');
  const setsInput = document.getElementById('custom-sets-input');
  const repsInput = document.getElementById('custom-reps-input');

  const name = nameInput.value.trim();
  if (!name) {
    alert("Zadejte prosím název cviku.");
    return;
  }

  const sCount = parseInt(setsInput.value, 10) || 3;
  const wKg = parseFloat(weightInput.value) || 0;
  const rCount = parseInt(repsInput.value, 10) || 10;

  const setsArray = [];
  for (let s = 1; s <= sCount; s++) {
    setsArray.push({
      setNumber: s,
      weightKg: wKg,
      reps: rCount,
      completed: false
    });
  }

  const newItem = {
    id: 'cust_' + Date.now(),
    exerciseId: 'custom_' + Date.now(),
    name: name,
    category: catInput.value,
    weightKg: wKg,
    targetSets: sCount,
    targetReps: rCount,
    progressionIncrementKg: 2.5,
    setsData: setsArray,
    notes: ""
  };

  AppState.workouts[AppState.currentTab].push(newItem);
  AppState.expandedItemIds.add(newItem.id);
  saveWorkoutsToStorage();

  // Reset
  nameInput.value = "";
  closeAddExerciseModal();
  renderExerciseList();
  showToast(`Vlastní cvik "${name}" byl přidán`);

  setTimeout(() => {
    const el = document.getElementById(`card-${newItem.id}`);
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
  }, 100);
}

// Sdílení aplikace a tréninku
async function shareWorkout() {
  const activeDay = AppState.days.find(d => d.id === AppState.currentTab);
  const dayTitle = activeDay ? activeDay.title : 'Trénink';
  const plan = AppState.workouts[AppState.currentTab] || [];
  
  let text = `💪 Cvičím podle aplikace Silový Trénink!\n\n`;
  text += `Můj aktuální ${dayTitle}:\n`;
  
  plan.forEach((item, index) => {
    ensureSetsData(item);
    const sets = item.setsData;
    const weights = sets.map(s => `${Number(s.weightKg).toFixed(1).replace('.0', '')} kg`);
    text += `${index + 1}. ${item.name} – ${sets.length} série: ${weights.join(', ')} (po ${sets[0].reps} reps)\n`;
  });
  
  text += `\nZkus tuto aplikaci pro přehledné plánování sérií a vah bez zbytečných obrázků!`;

  if (navigator.share) {
    try {
      await navigator.share({
        title: 'Silový Trénink',
        text: text,
        url: window.location.href
      });
    } catch (err) {
      if (err.name !== 'AbortError') {
        copyToClipboard(text);
      }
    }
  } else {
    copyToClipboard(text);
  }
}

function copyToClipboard(text) {
  navigator.clipboard.writeText(text).then(() => {
    showToast("Trénink zkopírován do schránky pro sdílení!");
  }).catch(() => {
    showToast("Trénink byl připraven ke sdílení.");
  });
}

function showToast(msg) {
  const toast = document.getElementById('toast');
  toast.textContent = msg;
  toast.classList.add('show');
  setTimeout(() => {
    toast.classList.remove('show');
  }, 2500);
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

// Inicializace event listenerů
document.addEventListener('DOMContentLoaded', () => {
  loadWorkoutsFromStorage();
  loadExerciseDatabase();
  renderTabBar();
  renderExerciseList();
  updateScheduleBanner();

  // Tlačítko Sdílet v horní liště
  document.getElementById('btn-share').addEventListener('click', shareWorkout);

  // Tlačítko "+ Přidat den" v horní liště
  document.getElementById('btn-open-add-day').addEventListener('click', openAddDayModal);

  // Modál pro přidání dne
  document.getElementById('btn-modal-day-close').addEventListener('click', closeAddDayModal);
  document.getElementById('btn-save-new-day').addEventListener('click', saveNewWorkoutDay);

  // Modál pro přidání cviku do aktuálního dne
  document.getElementById('btn-modal-close').addEventListener('click', closeAddExerciseModal);

  // Segmented přepínač v modálu cviků
  const segDb = document.getElementById('seg-db');
  const segCustom = document.getElementById('seg-custom');
  const secDb = document.getElementById('section-db-picker');
  const secCustom = document.getElementById('section-custom-exercise');

  segDb.addEventListener('click', () => {
    segDb.classList.add('active');
    segCustom.classList.remove('active');
    secDb.style.display = 'flex';
    secCustom.style.display = 'none';
  });

  segCustom.addEventListener('click', () => {
    segCustom.classList.add('active');
    segDb.classList.remove('active');
    secDb.style.display = 'none';
    secCustom.style.display = 'flex';
  });

  // Hledání v databázi cviků
  document.getElementById('db-search-input').addEventListener('input', renderDatabaseList);

  // Tlačítko "Upravit" v banneru vybraného dne
  document.getElementById('btn-edit-current-day')?.addEventListener('click', openEditDayModal);

  // Modál pro úpravu a smazání dne
  document.getElementById('btn-modal-edit-day-close')?.addEventListener('click', closeEditDayModal);
  document.getElementById('btn-save-edit-day')?.addEventListener('click', saveEditedWorkoutDay);
  document.getElementById('btn-delete-current-day')?.addEventListener('click', deleteCurrentWorkoutDay);

  // Uložení vlastního cviku
  document.getElementById('btn-save-custom').addEventListener('click', saveCustomExercise);
});
