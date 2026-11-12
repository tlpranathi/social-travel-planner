// A small offline embedding for classroom demonstration. It derives a query vector
// from the user's words; a production version would replace this with an embedding API.
export function queryEmbedding(query: string): string {
  const text = query.toLowerCase();
  let beach = 0.15, cultureNature = 0.15, foodActivity = 0.15;
  const add = (words: string[], target: "beach" | "cultureNature" | "foodActivity", amount: number) => {
    if (words.some(word => text.includes(word))) {
      if (target === "beach") beach += amount;
      if (target === "cultureNature") cultureNature += amount;
      if (target === "foodActivity") foodActivity += amount;
    }
  };
  add(["beach", "sea", "ocean", "coast", "sunset", "relax", "quiet", "peaceful", "swim"], "beach", 0.8);
  add(["church", "history", "heritage", "museum", "fort", "culture", "waterfall", "nature", "wildlife", "trek"], "cultureNature", 0.8);
  add(["food", "cafe", "restaurant", "seafood", "market", "party", "night", "adventure", "water sport"], "foodActivity", 0.8);
  return `[${beach.toFixed(2)},${cultureNature.toFixed(2)},${foodActivity.toFixed(2)}]`;
}
