using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NumberPool : MonoBehaviour
{
    public static NumberPool Instance
    {
        get
        {
            if (_instance == null) _instance = FindObjectOfType<NumberPool>();
            return _instance;
        }
    }

    private static NumberPool _instance;

    [SerializeField] List<GameObject> pooledNumbers = new List<GameObject>();
    
    public GameObject GetPooledObject(int numberToGet, Transform targetNode, bool wantActive)
    {
        for (int i = 0; i < pooledNumbers.Count; i++)
        {
            GameObject currentNumber = pooledNumbers[i];

            if (currentNumber.name.Equals(numberToGet.ToString()) && !currentNumber.GetComponent<Number>().isUsing)
            {
                currentNumber.GetComponent<Number>().isUsing = true;
                currentNumber.SetActive(wantActive);
                currentNumber.transform.SetParent(targetNode);
                currentNumber.transform.localScale = Vector3.one;
                currentNumber.transform.localPosition = Vector3.zero;
                return currentNumber;
            }
        }

        GameObject newBlock = Instantiate(Resources.Load("Nodes/" + numberToGet.ToString()), targetNode) as GameObject;
        newBlock.name = numberToGet.ToString();
        pooledNumbers.Add(newBlock);
        return newBlock;
    }

    public void SetPooledObject(Transform numberToPool)
    {
        numberToPool.GetComponent<Number>().isUsing = false;
        numberToPool.gameObject.SetActive(false);
        numberToPool.SetParent(transform);
    }
}
