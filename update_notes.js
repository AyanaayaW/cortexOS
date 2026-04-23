const fs = require('fs');
const path = require('path');

function createMindmap(title, subtopics, filepath) {
    const elements = [];
    let idCounter = 1;
    
    const cx = 400;
    const cy = 300;
    
    // Center node
    elements.push({
        type: "rectangle", id: `rect_${idCounter}`, x: cx - 120, y: cy - 40, width: 240, height: 80,
        strokeColor: "#1e1e1e", backgroundColor: "#e0e0e0", fillStyle: "solid", strokeWidth: 2,
        roughness: 1, opacity: 100, seed: idCounter, version: 1, versionNonce: 1, isDeleted: false,
        groupIds: [], boundElements: [], roundness: { type: 3 }
    });
    elements.push({
        type: "text", id: `text_${idCounter}`, x: cx - 100, y: cy - 15, width: 200, height: 30,
        strokeColor: "#000000", fontSize: 20, fontFamily: 1, text: title, textAlign: "center",
        verticalAlign: "middle", seed: idCounter, version: 1, versionNonce: 1, isDeleted: false,
        groupIds: [], boundElements: []
    });
    idCounter++;
    
    const angleStep = (Math.PI * 2) / subtopics.length;
    const radius = 200;
    
    subtopics.forEach((sub, i) => {
        const angle = i * angleStep;
        const sx = cx + radius * Math.cos(angle);
        const sy = cy + radius * Math.sin(angle);
        
        elements.push({
            type: "line", id: `line_${idCounter}`, x: cx, y: cy, width: Math.abs(sx - cx), height: Math.abs(sy - cy),
            points: [[0, 0], [sx - cx, sy - cy]], strokeColor: "#000000", strokeWidth: 2, roughness: 1, opacity: 100,
            seed: idCounter, version: 1, versionNonce: 1, isDeleted: false, groupIds: [], boundElements: []
        });
        
        elements.push({
            type: "text", id: `text_sub_${idCounter}`, x: sx - 80, y: sy - 15, width: 160, height: 30,
            strokeColor: "#000000", fontSize: 16, fontFamily: 1, text: sub, textAlign: "center",
            verticalAlign: "middle", seed: idCounter, version: 1, versionNonce: 1, isDeleted: false,
            groupIds: [], boundElements: []
        });
        idCounter++;
    });
    
    const excalidrawState = {
        type: "excalidraw", version: 2, source: "https://excalidraw.com", elements: elements,
        appState: { viewBackgroundColor: "#ffffff" }, files: {}
    };

    const mdContent = `---
excalidraw-plugin: parsed
tags: [excalidraw]
---
==⚠  Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠==

# Text Elements
${title}
${subtopics.join('\n')}

# Drawing
\`\`\`json
${JSON.stringify(excalidrawState, null, 2)}
\`\`\`
`;
    fs.writeFileSync(filepath, mdContent);
}

const mindmaps = [
    { title: "1.1 Markets", subs: ["Demand", "Supply", "Equilibrium", "Determinants"], file: "IBDP Economics/Microeconomics/1.1_Mindmap.excalidraw.md", targetFile: "IBDP Economics/Microeconomics/1.1_Competitive_Markets.md", mermaid: `\`\`\`mermaid
xychart-beta
    title "Market Equilibrium"
    x-axis "Quantity" [0, 20, 40, 60, 80, 100]
    y-axis "Price" 0 --> 100
    line "Demand" [100, 80, 60, 40, 20, 0]
    line "Supply" [0, 20, 40, 60, 80, 100]
\`\`\`` },
    { title: "1.2 Elasticities", subs: ["PED", "XED", "YED", "PES"], file: "IBDP Economics/Microeconomics/1.2_Mindmap.excalidraw.md", targetFile: "IBDP Economics/Microeconomics/1.2_Elasticities.md", mermaid: `\`\`\`mermaid
xychart-beta
    title "Elastic vs. Inelastic Demand"
    x-axis "Quantity" [0, 20, 40, 60, 80, 100]
    y-axis "Price" 0 --> 100
    line "Elastic (Flat)" [60, 55, 50, 45, 40, 35]
    line "Inelastic (Steep)" [90, 70, 50, 30, 10, 0]
\`\`\`` },
    { title: "1.3 Govt & Market Failure", subs: ["Taxes & Subsidies", "Price Controls", "Externalities", "Public Goods"], file: "IBDP Economics/Microeconomics/1.3_Mindmap.excalidraw.md", targetFile: "IBDP Economics/Microeconomics/1.3_Intervention_and_Market_Failure.md", mermaid: `\`\`\`mermaid
xychart-beta
    title "Negative Externality of Production"
    x-axis "Quantity" [0, 20, 40, 60, 80, 100]
    y-axis "Costs/Benefits" 0 --> 100
    line "MPB = MSB" [90, 75, 60, 45, 30, 15]
    line "MPC" [10, 25, 40, 55, 70, 85]
    line "MSC" [30, 45, 60, 75, 90, 100]
\`\`\`` },
    { title: "2.1 Econ Activity", subs: ["Circular Flow", "GDP & GNI", "Business Cycle", "Limitations"], file: "IBDP Economics/Macroeconomics/2.1_Mindmap.excalidraw.md", targetFile: "IBDP Economics/Macroeconomics/2.1_Level_of_Overall_Economic_Activity.md", mermaid: `\`\`\`mermaid
xychart-beta
    title "The Business Cycle"
    x-axis "Time" [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    y-axis "Real GDP" 0 --> 100
    line "Actual GDP" [40, 60, 80, 50, 30, 50, 70, 90, 60, 40]
    line "Trend" [40, 45, 50, 55, 60, 65, 70, 75, 80, 85]
\`\`\`` },
    { title: "2.2 AD & AS", subs: ["Aggregate Demand", "SRAS", "LRAS", "Equilibrium"], file: "IBDP Economics/Macroeconomics/2.2_Mindmap.excalidraw.md", targetFile: "IBDP Economics/Macroeconomics/2.2_Aggregate_Demand_and_Supply.md", mermaid: `\`\`\`mermaid
xychart-beta
    title "Keynesian AS Curve"
    x-axis "Real GDP (Y)" [0, 20, 40, 60, 80, 100]
    y-axis "Price Level" 0 --> 100
    line "AS" [20, 20, 20, 30, 60, 100]
\`\`\`` },
    { title: "2.3 Macro Objectives", subs: ["Unemployment", "Inflation", "Economic Growth", "Equity"], file: "IBDP Economics/Macroeconomics/2.3_Mindmap.excalidraw.md", targetFile: "IBDP Economics/Macroeconomics/2.3_Macroeconomic_Objectives.md", mermaid: `\`\`\`mermaid
xychart-beta
    title "Lorenz Curve"
    x-axis "Cumulative % of Population" [0, 20, 40, 60, 80, 100]
    y-axis "Cumulative % of Income" 0 --> 100
    line "Line of Equality" [0, 20, 40, 60, 80, 100]
    line "Lorenz Curve" [0, 5, 15, 30, 50, 100]
\`\`\`` }
];

mindmaps.forEach(m => {
    createMindmap(m.title, m.subs, m.file);
    
    let content = fs.readFileSync(m.targetFile, 'utf-8');
    
    // Replace SVG with Mermaid
    content = content.replace(/<svg[\s\S]*?<\/svg>/g, m.mermaid);
    
    // Prepend Excalidraw mindmap
    const mindmapEmbed = `![[${path.basename(m.file)}]]\n\n`;
    content = mindmapEmbed + content;
    
    fs.writeFileSync(m.targetFile, content);
});

console.log("Done processing all notes.");