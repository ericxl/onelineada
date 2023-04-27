#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using UnityEditor.Build.Reporting;
using System.IO;

public class Build : MonoBehaviour
{
    [MenuItem("Build/Build project %#U")]
    private static void BuildProject()
    {
        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();

        //Debug.LogError(Application.dataPath);

        var path = Path.Combine(Path.GetDirectoryName(Path.GetDirectoryName(Application.dataPath)), "iOSBuild");
        buildPlayerOptions.locationPathName = path;
        buildPlayerOptions.target = BuildTarget.iOS;

        Directory.CreateDirectory(buildPlayerOptions.locationPathName);
        //buildPlayerOptions.locationPathName = path;

        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
        BuildSummary summary = report.summary;

        if (summary.result == BuildResult.Succeeded)
        {
            Debug.Log("Build succeeded: " + summary.totalSize + " bytes");
        }

        if (summary.result == BuildResult.Failed)
        {
            Debug.LogError("Build failed: " + summary.result.ToString());
        }
    }
}

#endif