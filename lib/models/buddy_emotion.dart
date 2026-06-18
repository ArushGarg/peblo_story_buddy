/// The Buddy's emotional state, driven entirely by [StoryBuddyProvider]
/// so the same character can react to narration and quiz events
/// without the widget itself knowing why.
enum BuddyEmotion { idle, thinking, happy, sad }
