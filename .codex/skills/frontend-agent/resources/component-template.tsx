import type { FC } from "react";

type Props = {
  title: string;
};

export const FeatureCard: FC<Props> = ({ title }) => {
  return <div className="rounded-md border p-4">{title}</div>;
};