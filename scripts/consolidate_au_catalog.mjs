import fs from 'node:fs';
const p = 'index.html';
let t = fs.readFileSync(p, 'utf8');

const NEW = `const TRADE_CATALOG_AU = [
            // Consolidated to the trades you'd actually call back for a defect —
            // one discipline each, not per-stage splits. Codes are a representative
            // AU cost centre (optional). Edit/add/remove any in Manage.
            { cat:'Site & Structure', code:'', name:'Excavator / Earthworks' },
            { cat:'Site & Structure', code:'150', name:'Concreter', common:true },
            { cat:'Site & Structure', code:'', name:'Steel Fixer' },
            { cat:'Site & Structure', code:'310', name:'Bricklayer', common:true },
            { cat:'Site & Structure', code:'220', name:'Carpenter', common:true },
            { cat:'Site & Structure', code:'250', name:'Roofer', common:true },
            { cat:'Site & Structure', code:'230', name:'Roof Plumber & Gutters' },
            { cat:'Site & Structure', code:'265', name:'Scaffolder' },
            { cat:'Services', code:'270', name:'Plumber', common:true },
            { cat:'Services', code:'350', name:'Electrician', common:true },
            { cat:'Services', code:'680', name:'Air Conditioning & Heating' },
            { cat:'Services', code:'', name:'Gas Fitter' },
            { cat:'Services', code:'', name:'Solar Installer' },
            { cat:'Services', code:'370', name:'Data & Security' },
            { cat:'Linings & Finishes', code:'', name:'Insulation' },
            { cat:'Linings & Finishes', code:'440', name:'Plasterer', common:true },
            { cat:'Linings & Finishes', code:'460', name:'Renderer' },
            { cat:'Linings & Finishes', code:'570', name:'Painter', common:true },
            { cat:'Wet Areas & Joinery', code:'550', name:'Waterproofer', common:true },
            { cat:'Wet Areas & Joinery', code:'610', name:'Tiler', common:true },
            { cat:'Wet Areas & Joinery', code:'560', name:'Cabinet Maker', common:true },
            { cat:'Wet Areas & Joinery', code:'', name:'Stonemason (Benchtops)' },
            { cat:'Wet Areas & Joinery', code:'', name:'Glazier (Showers & Mirrors)' },
            { cat:'Fit-Out', code:'210', name:'Window & Door Installer', common:true },
            { cat:'Fit-Out', code:'660', name:'Garage Door Installer' },
            { cat:'Fit-Out', code:'470', name:'Stair Builder' },
            { cat:'Fit-Out', code:'525', name:'Balustrade Installer' },
            { cat:'Fit-Out', code:'810', name:'Floor Coverings', common:true },
            { cat:'Fit-Out', code:'790', name:'Blinds & Window Furnishings' },
            { cat:'External', code:'820', name:'Fencing' },
            { cat:'External', code:'840', name:'Landscaper' },
            { cat:'External', code:'740', name:'Paving & Driveway' },
            { cat:'External', code:'860', name:'Decking & Pergola' },
            { cat:'External', code:'730', name:'Retaining Walls' },
            { cat:'External', code:'780', name:'Letterbox & Clothesline' },
            { cat:'Final', code:'760', name:'Pest & Termite' },
            { cat:'Final', code:'830', name:'Cleaner', common:true },
            { cat:'Final', code:'870', name:'Appliance Installer' },
            { cat:'Final', code:'', name:'Surveyor' },
            { cat:'Final', code:'', name:'Building Inspector' },
            { cat:'Final', code:'', name:'Handyman / Maintenance' }
        ];`;

const re = /const TRADE_CATALOG_AU = \[[\s\S]*?\n {8}\];/;
if (!re.test(t)) { console.error('NO MATCH for TRADE_CATALOG_AU'); process.exit(1); }
const before = t.length;
t = t.replace(re, NEW);
fs.writeFileSync(p, t, 'utf8');
const n = (NEW.match(/\{ cat:/g) || []).length;
console.log(`Replaced AU catalogue. ${n} trades. file ${before} -> ${t.length} chars.`);
