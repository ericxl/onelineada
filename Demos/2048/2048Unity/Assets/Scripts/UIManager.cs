using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance
    {
        get
        {
            if (_instance == null) _instance = FindObjectOfType<UIManager>();
            return _instance;
        }
    }

    private static UIManager _instance;

    [SerializeField] GameObject gameOverPanel;
    [SerializeField] TMP_Text scoreText;
    [SerializeField] TMP_Text bestText;

    int score;
    int best;

    private void Start()
    {
        best = PlayerPrefs.GetInt("Best");
        bestText.text = best.ToString();
    }

    public void OnInput(int toAdd)
    {
        UpdateScoreText(toAdd);

        best = PlayerPrefs.GetInt("Best", 0);

        if (score > best)
        {
            best = score;
            PlayerPrefs.SetInt("Best", best);
            bestText.text = best.ToString();
        }
    }

    void UpdateScoreText(int toAdd)
    {
        score += toAdd;
        scoreText.text = score.ToString();
    }

    public void GameOver()
    {
        gameOverPanel.SetActive(true);
    }

    public void CreateNewGame()
    {
        SceneManager.LoadScene(0);
    }

    [ContextMenu("ResetAllPrefs")]
    void ResetAllPrefs()
    {
        PlayerPrefs.DeleteAll();
    }

}
