export function StatusMessage({
  message,
  tone = "error",
}: {
  message: string | null;
  tone?: "error" | "success";
}) {
  if (!message) {
    return null;
  }

  return <div className={tone === "success" ? "notice success" : "notice"}>{message}</div>;
}
