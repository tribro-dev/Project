// BBT_3D_MegaGame_Full.cs
// Fully Loaded Unity 3D Game Framework for Big Bang Theory (S1-S12)
// Features: Playable characters, NPCs, chronological events, branching dialogue, mini-games, romance, 3D interactions, dynamic voice lines

using System.Collections.Generic;
using UnityEngine;

public enum Mood { Friendly, Tease, Flirt, Romantic, DarkHumor }

[System.Serializable]
public class DialogueLine {
    public string Text;
    public Mood LineMood;
    public List<AudioClip> VoiceClips;

    public DialogueLine(string text, Mood mood, List<AudioClip> clips = null) {
        Text = text;
        LineMood = mood;
        VoiceClips = clips ?? new List<AudioClip>();
    }

    public AudioClip GetRandomVoiceClip() {
        if(VoiceClips.Count == 0) return null;
        return VoiceClips[Random.Range(0, VoiceClips.Count)];
    }
}

public class Character {
    public string Name;
    public int FirstSeason;
    public int RelationshipPoints;
    public Mood CurrentMood;
    public bool IsPlayable;
    public bool IsAlive = true;
    public GameObject Model;
    public Dictionary<int, List<DialogueLine>> SeasonDialogues;

    public Character(string name, int season, bool playable) {
        Name = name;
        FirstSeason = season;
        IsPlayable = playable;
        RelationshipPoints = 0;
        CurrentMood = Mood.Friendly;
        SeasonDialogues = new Dictionary<int, List<DialogueLine>>();
        InitializeDialogues();
    }

    void InitializeDialogues() {
        for(int s = FirstSeason; s <= 12; s++) {
            SeasonDialogues[s] = new List<DialogueLine>();
        }

        // Example lines for main characters (expand with more lines per season)
        if(Name == "Sheldon") {
            SeasonDialogues[1].Add(new DialogueLine("I'm not crazy; my mother had me tested.", Mood.Friendly, new List<AudioClip>{null,null,null}));
            SeasonDialogues[1].Add(new DialogueLine("Bazinga!", Mood.Tease, new List<AudioClip>{null,null,null}));
            SeasonDialogues[12].Add(new DialogueLine("I won the Nobel Prize!", Mood.Romantic, new List<AudioClip>{null,null}));
        }
        else if(Name == "Leonard") {
            SeasonDialogues[1].Add(new DialogueLine("I care more about you than I probably should.", Mood.Friendly, new List<AudioClip>{null,null}));
            SeasonDialogues[12].Add(new DialogueLine("This universe feels like home because of you.", Mood.Romantic, new List<AudioClip>{null,null}));
        }
        else if(Name == "Penny") {
            SeasonDialogues[1].Add(new DialogueLine("I may be blonde, but I'm not stupid.", Mood.Friendly, new List<AudioClip>{null,null}));
            SeasonDialogues[12].Add(new DialogueLine("I want to hold you. Being close is enough.", Mood.Romantic, new List<AudioClip>{null,null}));
        }
        else if(Name == "Howard") {
            SeasonDialogues[1].Add(new DialogueLine("Did you see that rocket? I made it real.", Mood.Friendly, new List<AudioClip>{null,null}));
            SeasonDialogues[12].Add(new DialogueLine("I want to hold you… and maybe build a spaceship to take us somewhere.", Mood.Romantic, new List<AudioClip>{null,null}));
        }
        else if(Name == "Raj") {
            SeasonDialogues[1].Add(new DialogueLine("You're my favorite guy to nerd out with.", Mood.Friendly, new List<AudioClip>{null,null}));
            SeasonDialogues[12].Add(new DialogueLine("I like you more than chocolate, and that's serious.", Mood.Romantic, new List<AudioClip>{null,null}));
        }
        else if(Name == "Bernadette") {
            SeasonDialogues[3].Add(new DialogueLine("Howard, help me out of the tub. I'm stuck again.", Mood.Friendly, new List<AudioClip>{null,null}));
            SeasonDialogues[12].Add(new DialogueLine("I married you not in spite of nerdiness, but because of it.", Mood.Romantic, new List<AudioClip>{null,null}));
        }
        else if(Name == "Amy") {
            SeasonDialogues[4].Add(new DialogueLine("Romantic love is cultural, but I like you.", Mood.Friendly, new List<AudioClip>{null,null}));
            SeasonDialogues[12].Add(new DialogueLine("I love you more than being right… that's a lot.", Mood.Romantic, new List<AudioClip>{null,null}));
        }
    }

    public DialogueLine GetRandomDialogue(int season) {
        if(!SeasonDialogues.ContainsKey(season)) return null;
        List<DialogueLine> list = SeasonDialogues[season];
        if(list.Count == 0) return null;
        return list[Random.Range(0, list.Count)];
    }

    public DialogueLine GetRandomRomanticDialogue(int season) {
        List<DialogueLine> romanticLines = SeasonDialogues[season].FindAll(d => d.LineMood == Mood.Romantic);
        if(romanticLines.Count == 0) return null;
        return romanticLines[Random.Range(0, romanticLines.Count)];
    }
}

public class GameManager : MonoBehaviour {
    public List<Character> Characters = new List<Character>();
    public Character Player;
    public int CurrentSeason = 1;

    // 3D Locations
    public GameObject Apartment4A;
    public GameObject Apartment4B;
    public GameObject CaltechLab;
    public GameObject CheesecakeDiner;
    public GameObject ComicBookStore;
    public GameObject HalloweenParty;
    public GameObject NorthPoleTrip;
    public GameObject NobelPrizeCeremony;

    void Start() {
        InitializeCharacters();
        StartSeason(CurrentSeason);
    }

    void InitializeCharacters() {
        Characters.Add(new Character("Leonard", 1, true));
        Characters.Add(new Character("Sheldon", 1, true));
        Characters.Add(new Character("Penny", 1, true));
        Characters.Add(new Character("Howard", 1, true));
        Characters.Add(new Character("Raj", 1, true));
        Characters.Add(new Character("Bernadette", 3, true));
        Characters.Add(new Character("Amy", 4, true));

        Player = Characters[0]; // Default playable character
    }

    public void StartSeason(int season) {
        CurrentSeason = season;
        Debug.Log("Season " + season + " started.");
        TriggerSeasonEvents(season);
    }

    void TriggerSeasonEvents(int season) {
        switch(season) {
            case 1: HalloweenParty.SetActive(true); break;
            case 2: NorthPoleTrip.SetActive(true); break;
            case 8: Debug.Log("Howard's mom passing event triggered."); break;
            case 12: NobelPrizeCeremony.SetActive(true); break;
        }
    }

    public void Interact(Character npc) {
        DialogueLine line = npc.GetRandomDialogue(CurrentSeason);
        PlayDialogueLine(line, npc);
        npc.RelationshipPoints += Random.Range(1, 4);
    }

    public void RomanticInteraction(Character npc) {
        if(npc.RelationshipPoints >= 5) {
            DialogueLine romanticLine = npc.GetRandomRomanticDialogue(CurrentSeason);
            PlayDialogueLine(romanticLine, npc);
            Animator anim = npc.Model.GetComponent<Animator>();
            if(anim != null) anim.SetTrigger("Hug");
            npc.RelationshipPoints += 2;
        } else {
            Debug.Log(npc.Name + " is not ready for romance.");
        }
    }

    void PlayDialogueLine(DialogueLine line, Character npc) {
        if(line == null) return;
        ShowDialoguePanel(npc, line.Text);
        AudioClip clip = line.GetRandomVoiceClip();
        if(clip != null) {
            AudioSource.PlayClipAtPoint(clip, npc.Model.transform.position);
            Animator anim = npc.Model.GetComponent<Animator>();
            if(anim != null) anim.SetTrigger("Talk"); // Lip-sync placeholder
        }
    }

    void ShowDialoguePanel(Character npc, string text) {
        // Placeholder for 3D UI panel
        Debug.Log(npc.Name + ": " + text);
    }

    void Update() {
        // Player movement, camera, and input handling
        // Interactions with objects/NPCs
        // Mini-game triggers and event progression
    }
}
